#!/usr/bin/env perl
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# geekalicious.social Parser v0.1
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

(my $curl = <<~"CURL") =~ s`(^\s+)|\n`$1 ? q|| : q| |`megs;
	curl -sSL
	\x{27}%s\x{27}
CURL
	
####################################### INIT
	
$cmd     = sprintf $curl, qq|https://geekalicious.social/t/nerdy-news|;
$html    = qx|$cmd| =~ s`\s+|\t|\n+` `gr;

&statusCode ($?, $cmd);

$parser  = &initParse($html);

# collect titles / urls
&parseMainPage   ( $parser );

# replace $parser with matches
$parser = &returnMatches ($parser);

# add body text to matches
&parsePostBodies ( $parser );

# print out matches in JSON
say &encode_json( $parser );

####################################### SUBS

sub parseMainPage($)
{
	my $parser = shift;
	
	&skipUntil($parser, qr~<h2>All\sDiscussions</h2>~);
	
	while ( &lookAhead($parser, qr~https://geekalicious.social/d/~) )
	{
		&skipUntil ($parser, qr~<li>\s*?<a href="~);
		&saveUntil ($parser, qr~[^"]+~,q|url|);
		&skipUntil ($parser, qr~">~);
		&saveUntil ($parser, qr~[^<]+~,q|title|);
		
		&insertDiv ($parser);
	}
}

sub parsePostBodies($)
{
	my $parse = shift;
	
	for my $key (keys @{$parser})
	{
		if ($parser->[$key]->{url})
		{
			$cmd  = sprintf $curl, $parser->[$key]->{url};
			$html = qx|$cmd| =~ s`\s+|\t+|\n+` `gr;
			
			&statusCode ($?, $cmd);
			
			my $parserURL = &initParse($html);
			my $reArticle = qr~<meta\sname="description"~;
			
			if ( &lookAhead($parserURL, $reArticle) )
			{
				# debug: print all parsed urls
				# say qq|> Parsing ${key}/${\ scalar @{$parser} }: ${\ $parser->[$key]->{title} }...|;
				
				&skipUntil ($parserURL, $reArticle);
				&skipUntil ($parserURL, qr~"text":~);
				&saveUntil ($parserURL, qr~[^\n]+(?=","dateCreated":?)~i, q|text|);
				&insertDiv ($parserURL); 
				
				$parser->[$key]->{text} = &returnMatches($parserURL)->[0]->{text} =~ s`"?\\u003Cp\\u003E|\\u003C\\/p\\u003E|\\u2019``gr;
				
				$parser->[$key]->{text} =~ s`","dateCreated":.*$``g;
				
				&sleepyTime(5,5);
			}
			
		}
		
	}

}


__END__
