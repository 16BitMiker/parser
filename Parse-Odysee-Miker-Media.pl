#!/usr/bin/env perl
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# Odysee Miker Media Parser v0.1
# by https://miker.media

####################################### BEGIN

BEGIN { push @INC, '.' }

####################################### PRAGMAS

use v5.32;
use utf8;
use warnings;

use feature        qw|say|;
use Data::Dump     qw|dump|;
use JSON::MaybeXS  qw|encode_json|;
use Miker::Parser  qw|initParse insertDiv skipUntil saveUntil lookAhead returnMatches|;
use Miker::Basics  qw|sleepyTime statusCode|;

####################################### VARS

my $cmd;     # cURL command
my $html;    # html return
my $parser;  # parser content

####################################### HEREDOC

(my $watir = <<~'WATIR') =~ s`(^\s+)|\n`$1 ? q|| : q| |`megs;
	ruby -r 'watir' -se '@b = Watir::Browser.new(:firefox, headless: true); @b.goto($url); sleep 10; puts @b.html.gsub(%r~\n|\s+|\t+~, %q| |);' -- -url='https://odysee.com/@miker.media:9'
WATIR

####################################### INIT

$html = qx|$watir| =~ s`<style>[^\n]+?</style>``gr;

&statusCode ($?, $cmd);

$parser  = &initParse($html);

# collect odysee info
&parseOdysee   ( $parser );

# replace $parser with matches
$parser = &returnMatches ($parser);

# add odysee.com to url
&corretions ($parser);

# print out matches in JSON
say &encode_json( $parser );

####################################### SUBS

sub parseOdysee($)
{
	my $parser = shift;
	
	my $vidRegex = qr~claim-preview--tile">[^\n]+?href="~;
	
	while ( &lookAhead($parser, $vidRegex) )
	{
		&skipUntil ($parser, $vidRegex);
		&saveUntil ($parser, qr~[^"]+~,q|url|);
		&skipUntil ($parser, qr~data-background-image="https://thumbnails.odycdn.com/optimize/s:390:220/quality:85/plain/~);
		&saveUntil ($parser, qr~[^"]+~,q|thumbnail|);
		&skipUntil ($parser, qr~claim-tile__header"><a\saria-label="~);
		&saveUntil ($parser, qr~[^"]+(?="\shref=")~,q|title|);
		
		&insertDiv ($parser);
	}
}

sub corretions($)
{
	
	my $parser = shift;
	
	for my $key (keys @{$parser})
	{
		
		$parser->[$key]->{title} =~ s`^(.*)\sby.*`$1`;
		$parser->[$key]->{url} = q|https://odysee.com/| . $parser->[$key]->{url};
		
	}
	
}

__END__