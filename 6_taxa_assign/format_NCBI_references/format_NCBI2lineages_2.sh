#!/usr/bin/perl
#use diagnostics;
#use warnings;
#use strict;

my $input = $ARGV[0];
open (MYFILE, $input);
my @file = <MYFILE>;
close (MYFILE);

open (NEW_FILE, '>>edit_lineage.out');
my @new_file=();
	foreach my $line (@file) {
		my @fields = split (/\s+/, $line);
		push (@new_file, ("$fields[0] $fields[1]+$fields[2]\n"));
		}
		print NEW_FILE @new_file;
	


