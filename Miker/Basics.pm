#!/usr/bin/env perl
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# Miker Basics v0.1
# by https://miker.media

####################################### PACKAGE PRAGMAS REQUIRE

package Miker::Basics;
require Exporter;
use     utf8;

####################################### GLOBAL VARS

@ISA    = qw|Exporter|;
@EXPORT = qw|sleepyTime statusCode|;

####################################### SUBS

sub sleepyTime($$)
{
	my $random = shift;
	my $static = shift;
	
	sleep ( ( int( rand ( $random ) ) ) + $static );
}

sub statusCode($;$)
{
	my $runCode = shift;
	my $cmd     = undef;
	
	if (@_)
	{
		$cmd = shift;
	}
	
	unless ($runCode == 0)
	{
		print qq|> ${cmd}\n| if $cmd;
		print qq|> Error code ${$runCode} detected so quitting!\n|;
		exit 69;
	}
}

1;