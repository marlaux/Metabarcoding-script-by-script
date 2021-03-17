#!/usr/bin/perl
#use diagnostics;
#use warnings;
#use strict;

my $arq1 = "my_reference.acc2taxid2lineage2";
open (MYFILE, $arq1);
my @file = <MYFILE>;
close (MYFILE);

open (NEW_FILE, '>>final_formated_reference_header.txt');
my @new_file=();
	foreach my $line (@file) {
		my @fields = split (/\s+/, $line);
		push (@new_file, ("$fields[0] $fields[1]+$fields[2]\n"));
		}
		print NEW_FILE @new_file;
	


