#!/usr/bin/perl
#use diagnostics;
#use warnings;
#use strict;

my $arq1 = "Blast_results_formatted2OTUtable.tab";
open (MYFILE, $arq1);
my @file = <MYFILE>;
close (MYFILE);

open (NEW_FILE, '>>training_set_OTU_tax_assignments.txt');
print NEW_FILE "amplicom\tkingdom\tphylum\tclass\torder\tfamily\tgenus\tspecie\tidentity\n";
my @new_file=();
	foreach my $line (@file) {
		my @fields = split (/\s+/, $line);
		my @lineage = split (/\|/, $fields[3]);
		my @specie = split (/\+/, $lineage[6]);
		push (@new_file, ("$fields[0]\t$lineage[0]\t$lineage[1]\t$lineage[2]\t$lineage[3]\t$lineage[4]\t$lineage[5]\t$specie[1]\t$fields[2]\n"));
		}
		print NEW_FILE @new_file;
	


