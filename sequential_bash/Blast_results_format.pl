#!/usr/bin/perl
use diagnostics;
use warnings;
use strict;

print "Blast results file to edit:\t";
my $arq1 = <STDIN>;
chomp $arq1;
open (MYFILE, $arq1);
my @file = <MYFILE>;
close (MYFILE);


open (NEW_FILE, '>>Blast_results_formatted2OTUtable.tab');
my @new_file=();
        foreach my $line (@file) {
                my @fields = split (/\s+/, $line);
		my @seqid = split (/_/, $fields[0]);
		my $abundance = $seqid[1];
		my @acc = split (/\|/, $fields[3]);
		#my $abundance =~ s/[a-z=;]//ig;
                push (@new_file, ("$seqid[0]\t$abundance\t$fields[1]\t$fields[2]\t$acc[1]\t$fields[4]\n"));
         }
print NEW_FILE @new_file;

#perl tax_trace.pl taxdump/nodes.dmp taxdump/names.dmp taxids.txt taxids_export.txt
#

