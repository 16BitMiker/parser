#!/usr/bin/env perl
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# StarControl II Mod/Mp3 Download/Parser v0.1
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
	
$cmd  = sprintf $curl, qq|https://wiki.uqm.stack.nl/Star_Control_Music|;
$html = qx|$cmd| =~ s`\s+|\t|\n+` `gr;

&statusCode($?, $cmd);

# initialize parser
$parser  = &initParse($html);

# parse that wiki
&parseWiki ($parser);

# replace parser with matches
$parser = &returnMatches ($parser);

# cleanup titles
&cleanUp ($parser);

# download music titles
&dlMusic ($parser);

####################################### SUBS

sub parseWiki($)
{
	my $parser = shift;
	
	my $re = qr|<h4><span\sclass="mw-headline"\s|;
	
	while ( &lookAhead($parser, $re) )
	{
		&skipUntil ($parser, $re);
		&saveUntil ($parser, qr~(?<=id=")[^"]+~,q|title|);
		&skipUntil ($parser, qr~href="~);
		&saveUntil ($parser, qr~[^"]+(?:mod|mp3)(?=")~,q|music|);
		
		&insertDiv ($parser);
	}
}

sub cleanUp($)
{
	my $parse = shift;
	
	for my $key (keys @{$parser})
	{
		if ($parser->[$key]->{title})
		{
			$parser->[$key]->{title} =~ s`_` `g;
		}
	}
}

sub dlMusic($)
{
	my $parse = shift;
	
	for my $key (keys @{$parser})
	{
		if ($parser->[$key]->{title} and $parser->[$key]->{music})
		{
			say qq|> Downloading: ${\ $parser->[$key]->{title} }...|;
		
			system qq|curl --progress-bar -O ${\ $parser->[$key]->{music} }|;
			
			&statusCode ($?, 'Curl Download');
			
			&sleepyTime (7,5);
		}
	}
}

__END__