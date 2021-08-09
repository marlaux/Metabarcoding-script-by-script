#!/usr/bin/perl
use diagnostics;
use warnings;
use strict;
package ECHO_MODULE;
package main;

print "#####DEMULTIPLEXING DUAL INDEXED LIBRARIES#####\n";
print "EXPECTED INPUT:\nsample1\ttagF\ttagR\nsample2\ttagF\ttagR\n...\t#same as in your excel file\n##DO NOT INCLUDE PRIMERS NOW\n\n";
print "Please, enter your mapping file to edit:\t";
my $arq1 = <STDIN>;
chomp $arq1;
open (MYFILE, $arq1);
my @file = <MYFILE>;
close (MYFILE);

print ">>>For Illumina merged reads type 'linked'\n>>>For Illumina combinatorial type 'combinatorial'\n>>>For Illumina exact paired dual index type 'unique'\n>>>For Ion torrent dual index type 'ion'\n>>>For Ion dual index 3' anchored 'ion3'\n>>>For Ion dual index 5' anchored 'ion5'\n>>>For Ion dual index both anchored 'ion-both'\t";
chop (my $subname = <STDIN>);
if ($subname eq 'linked') {
	&linked;
}
if ($subname eq 'combinatorial')	{
	&combinatorial;
}
if ($subname eq 'unique')    {
        &unique;
}
if ($subname eq 'ion')       {
        &ion;
}
if ($subname eq 'ion3')       {
        &ion3;
}
if ($subname eq 'ion5')       {
        &ion5;
}
elsif ($subname eq 'ion-both')	{
	&ionboth;
}

sub linked
{
open (NEW_FILE1, '>>Barcodes_LA1.fa');
open (NEW_FILE2, '>>Barcodes_LA2.fa');
open (NEW_FILE3, '>>Barcodes_LA3.fa');
my @new_file1=();
my @new_file2=();
my @new_file3=();
        foreach my $line (@file) {
			chomp ($line);
			$line =~ s/\R//g;
                        my @fields= split(/\t/, $line);
			my $sample=$fields[0];
			my $tag_F=$fields[1];
			my $tag_R=$fields[2];
			my $RCtagF=reverse $tag_F;
			$RCtagF =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagF =~ s/[^\p{PosixAlnum},]//g;
			my $RCtagR=reverse $tag_R;
			$RCtagR =~ tr/ATGCatgc/TACGtacg/; 
			$RCtagR =~ s/[^\p{PosixAlnum},]//g;
			push (@new_file1, (">$sample\n^$tag_F...$tag_R\$\n"));	
			push (@new_file2, (">$sample\n^$RCtagR...$RCtagF\$\n"));
			push (@new_file3, (">$sample\n^$tag_F...$RCtagR\$\n"));
			}
        print NEW_FILE1 @new_file1;
	print NEW_FILE2 @new_file2;
	print NEW_FILE3 @new_file3;
}
sub combinatorial
{
open (NEW_FILE1, '>>Barcodes_F.fa');
open (NEW_FILE2, '>>Barcodes_R.fa');
my @new_file1=();
my @new_file2=();
        foreach my $line (@file) {
                        chomp ($line);
                        $line =~ s/\R//g;
			my @fields= split(/\t/, $line);
                        my $sample=$fields[0];
                        my $tag_F=$fields[1];
                        my $tag_R=$fields[2];
			push (@new_file1, (">$sample\n$tag_F\n"));
                        push (@new_file2, (">$sample\n^$tag_R\n"));
			}
        print NEW_FILE1 @new_file1;
        print NEW_FILE2 @new_file2;
}
sub unique
{
open (NEW_FILE1, '>>Barcode_R1.fa');
open (NEW_FILE2, '>>Barcode_R2.fa');
open (NEW_FILE3, '>>Barcode_R1_RC.fa');
open (NEW_FILE4, '>>Barcode_R2_RC.fa');
my @new_file1=();
my @new_file2=();
my @new_file3=();
my @new_file4=();
        foreach my $line (@file) {
                        chomp ($line);
                        my @fields= split(/\t/, $line);
                        my $sample=$fields[0];
                        my $tag_F=$fields[1];
                        my $tag_R=$fields[2];
                        my $RCtagF=reverse $tag_F;
                        $RCtagF =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagF =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagR=reverse $tag_R;
                        $RCtagR =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagR =~ s/[^\p{PosixAlnum},]//g;
                        push (@new_file1, (">$sample\n$tag_F\n"));
                        push (@new_file2, (">$sample\n$tag_R\n"));
                        push (@new_file3, (">$sample\n$RCtagF\n"));
			push (@new_file4, (">$sample\n$RCtagR\n"));
                        }
        print NEW_FILE1 @new_file1;
        print NEW_FILE2 @new_file2;
        print NEW_FILE3 @new_file3;
	print NEW_FILE4 @new_file4;
}
sub ion
{
open (ALT1, '>>Barcodes_alt1.fa');
open (ALT2, '>>Barcodes_alt2.fa');
open (ALT3, '>>Barcodes_alt3.fa');
open (ALT4, '>>Barcodes_alt4.fa');
my @tags_alt_1=();
my @tags_alt_2=();
my @tags_alt_3=();
my @tags_alt_4=();
	foreach my $line (@file) {
                        my @fields= split(/\t/, $line);
                        my $sample=$fields[0];
                        my $tag_F=$fields[1];
                        my $tag_R=$fields[2];
			$tag_F =~ s/[^\p{PosixAlnum},]//g;
			$tag_R =~ s/[^\p{PosixAlnum},]//g;
			my $RCtagF=reverse $tag_F;
                        $RCtagF =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagF =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagR=reverse $tag_R;
                        $RCtagR =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagR =~ s/[^\p{PosixAlnum},]//g;
                        push (@tags_alt_1, (">$sample\n$tag_F...$RCtagR\n"));
			push (@tags_alt_2, (">$sample\n$RCtagF...$tag_R\n"));
			push (@tags_alt_3, (">$sample\n$tag_R...$RCtagF\n"));
			push (@tags_alt_4, (">$sample\n$RCtagR...$tag_F\n"));
                        }
        print ALT1 @tags_alt_1;
	print ALT2 @tags_alt_2;
	print ALT3 @tags_alt_3;
	print ALT4 @tags_alt_4;
}
sub ion3
{
open (ALT1, '>>Barcodes_alt1_3anch.fa');
open (ALT2, '>>Barcodes_alt2_3anch.fa');
open (ALT3, '>>Barcodes_alt3_3anch.fa');
open (ALT4, '>>Barcodes_alt4_3anch.fa');
my @tags_alt_1_3anch=();
my @tags_alt_2_3anch=();
my @tags_alt_3_3anch=();
my @tags_alt_4_3anch=();
        foreach my $line (@file) {
                        my @fields= split(/\t/, $line);
                        my $sample=$fields[0];
                        my $tag_F=$fields[1];
                        my $tag_R=$fields[2];
                        $tag_F =~ s/[^\p{PosixAlnum},]//g;
                        $tag_R =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagF=reverse $tag_F;
                        $RCtagF =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagF =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagR=reverse $tag_R;
                        $RCtagR =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagR =~ s/[^\p{PosixAlnum},]//g;
                        push (@tags_alt_1_3anch, (">$sample\n$tag_F...$RCtagR\$\n"));
                        push (@tags_alt_2_3anch, (">$sample\n$RCtagF...$tag_R\$\n"));
                        push (@tags_alt_3_3anch, (">$sample\n$tag_R...$RCtagF\$\n"));
                        push (@tags_alt_4_3anch, (">$sample\n$RCtagR...$tag_F\$\n"));
                        }
        print ALT1 @tags_alt_1_3anch;
        print ALT2 @tags_alt_2_3anch;
        print ALT3 @tags_alt_3_3anch;
        print ALT4 @tags_alt_4_3anch;
}
sub ion5
{
open (ALT1, '>>Barcodes_alt1_5anch.fa');
open (ALT2, '>>Barcodes_alt2_5anch.fa');
open (ALT3, '>>Barcodes_alt3_5anch.fa');
open (ALT4, '>>Barcodes_alt4_5anch.fa');
my @tags_alt_1_5anch=();
my @tags_alt_2_5anch=();
my @tags_alt_3_5anch=();
my @tags_alt_4_5anch=();
        foreach my $line (@file) {
                        my @fields= split(/\t/, $line);
                        my $sample=$fields[0];
                        my $tag_F=$fields[1];
                        my $tag_R=$fields[2];
                        $tag_F =~ s/[^\p{PosixAlnum},]//g;
                        $tag_R =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagF=reverse $tag_F;
                        $RCtagF =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagF =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagR=reverse $tag_R;
                        $RCtagR =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagR =~ s/[^\p{PosixAlnum},]//g;
                        push (@tags_alt_1_5anch, (">$sample\n^$tag_F...$RCtagR\n"));
                        push (@tags_alt_2_5anch, (">$sample\n^$RCtagF...$tag_R\n"));
                        push (@tags_alt_3_5anch, (">$sample\n^$tag_R...$RCtagF\n"));
                        push (@tags_alt_4_5anch, (">$sample\n^$RCtagR...$tag_F\n"));
                        }
        print ALT1 @tags_alt_1_5anch;
        print ALT2 @tags_alt_2_5anch;
        print ALT3 @tags_alt_3_5anch;
        print ALT4 @tags_alt_4_5anch;
}
sub ionboth
{
open (ALT1, '>>Barcodes_alt1_bothanch.fa');
open (ALT2, '>>Barcodes_alt2_bothanch.fa');
open (ALT3, '>>Barcodes_alt3_bothanch.fa');
open (ALT4, '>>Barcodes_alt4_bothanch.fa');
my @tags_alt_1_bothanch=();
my @tags_alt_2_bothanch=();
my @tags_alt_3_bothanch=();
my @tags_alt_4_bothanch=();
        foreach my $line (@file) {
                        my @fields= split(/\t/, $line);
                        my $sample=$fields[0];
                        my $tag_F=$fields[1];
                        my $tag_R=$fields[2];
                        $tag_F =~ s/[^\p{PosixAlnum},]//g;
                        $tag_R =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagF=reverse $tag_F;
                        $RCtagF =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagF =~ s/[^\p{PosixAlnum},]//g;
                        my $RCtagR=reverse $tag_R;
                        $RCtagR =~ tr/ATGCatgc/TACGtacg/;
                        $RCtagR =~ s/[^\p{PosixAlnum},]//g;
                        push (@tags_alt_1_bothanch, (">$sample\n^$tag_F...$RCtagR\$\n"));
                        push (@tags_alt_2_bothanch, (">$sample\n^$RCtagF...$tag_R\$\n"));
                        push (@tags_alt_3_bothanch, (">$sample\n^$tag_R...$RCtagF\$\n"));
                        push (@tags_alt_4_bothanch, (">$sample\n^$RCtagR...$tag_F\$\n"));
                        }
        print ALT1 @tags_alt_1_bothanch;
        print ALT2 @tags_alt_2_bothanch;
        print ALT3 @tags_alt_3_bothanch;
        print ALT4 @tags_alt_4_bothanch;
}

