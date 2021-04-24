#!/usr/bin/perl
use diagnostics;
use warnings;
use strict;
use Bio::SeqIO;

my $file = $ARGV[0];
my $prefix = $ARGV[1];
my %unique;
my $seqio  = Bio::SeqIO->new(-file => $file, -format => "fasta");
my $outseq = Bio::SeqIO->new(-file => ">$prefix.uniq.fasta", -format => "fasta");

while(my $seqs = $seqio->next_seq) {
  my $id  = $seqs->display_id;
  my $seq = $seqs->seq;
  unless(exists($unique{$seq})) {
    $outseq->write_seq($seqs);
    $unique{$seq} +=1;
  }
}
