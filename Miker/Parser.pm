#!/usr/bin/env perl
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# Text Parser v0.1
# by https://miker.media

####################################### PACKAGE PRAGMAS REQUIRE

package Miker::Parser;
require Exporter;
use     utf8;

####################################### GLOBAL VARS

@ISA    = qw|Exporter|;
@EXPORT = qw|initParse insertDiv skipUntil saveUntil lookAhead returnMatches|;

####################################### SUBS

sub initParse($)
{
	my $parse;
	
	$parse  =  [];
	my $content =  shift;
	$content    =~ s`\s{2,}``g;
	
	push @{$parse}, $content;
	&insertDiv($parser);
	
	return $parse;
}

sub insertDiv($)
{
	my $parse = shift;
	my $div = q|-|x10;
	push @{$parse}, $div;
}

sub skipUntil($$)
{
	my $parse   = shift;
	my $re      = shift;
	my $content =  $parse->[0];
	
	$content =~ s`(?<pruned>.*?${re})(?<kept>.*)`
		push @{$parse}, { type => q|skip|, content => $+{pruned} } if $+{pruned};
		$parse->[0] = $+{kept} if $+{kept};
	`smer;
	
}

sub saveUntil($$$)
{
	my $parse   =  shift;
	my $re      =  shift;
	my $label   =  shift;
	my $content =  $parse->[0];
	
	$content =~ s`(?<saved>${re})(?<kept>.*)`
		push @{$parse}, { type => q|save|, label => $label, content => $+{saved} } if $+{saved};
		$parse->[0] = $+{kept} if $+{kept};
	`smer;
}

sub lookAhead($$)
{
	my $parse    =  shift;
	my $re       =  shift;
	my $content  =  $parse->[0];
	
	if ($content =~ m`.*?${re}`ms)
	{
		return 1;
	}
	else 
	{
		return 0;
	}
}

sub returnMatches($)
{
	my $parse   =  shift;
	my $results = [];
	my $div     = q|-|x10;
	my $n       = 0;
	
	for my $key (keys @{$parse})
	{
		next unless $key >= 1;
		
		if ($parse->[$key] eq $div)
		{
			$key >= 2 ? $n++ : $n;
			next;
		}
		
		if ($parse->[$key]->{label})
		{
			$results->[$n]->{$parse->[$key]->{label}} = $parse->[$key]->{content} =~ s`^\s+|\s+$``gr;
		}
	}
	
	return $results;
}

1;

__END__


