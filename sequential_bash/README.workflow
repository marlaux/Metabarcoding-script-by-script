##########################
Lib1_R1_subsampled.fastq
Lib1_R2_subsampled.fastq
barcodes_subsample.txt
##########################
vi merge_pear.sh
edit, save
bash: ./merge_pear.sh
slurm: sbatch run_merge_pear.slurm
output:
training_set.assembled.fastq
grep -c "^@M" training_set.assembled.fastq
9966
###########################
perl preparing_tags_LCPI.pl
	>barcodes_subsample.txt
	>linked
	Barcodes_LA1.fa - LA3.fq
vi demulti_dual_index_linked.sh
edit INPUT="training_set.assembled.fastq"  
bash: ./demulti_dual_index_linked.sh
slurm: vi run_demulti_cutadapt.slurm
	   uncomment demulti_dual_index_linked.sh and comment others .sh
	   save and run:
	   sbatch run_demulti_cutadapt.slurm
count the reads by sample:
vi counting_reads.sh
check demultiplexed samples directory and suffix (fastq or fq)
count ./counting_reads.sh
head counting_demulti_reads.txt
demulti_linked/AI1a_II_LA.fq:13
demulti_linked/AI1a_I_LA.fq:49
demulti_linked/AI1a_IV_LA.fq:19
demulti_linked/AI1b_II_LA.fq:227
#####################################################################
copy the tags fasta files used for demultiplexing:
cp ../2_demulti/Barcodes_LA* .
wrapped scripts:
vi tag_primer_clipping_part1.sh --> tags and primers removal
edit demultiplexed samples directory and suffix
save and run
./tag_primer_clipping_part1.sh
output: clipped directory
cd clipped, ls
*_trim1.fq --> without tags
*_trim2.fq --> without tags and primers
check the loss and shortening of reads:
awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("total %d avg=%f stddev=%f\n",n,m,sq/n-m*m);}' *LA.fq
	total 9966 avg=476.160144 stddev=1435.144934
awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("total %d avg=%f stddev=%f\n",n,m,sq/n-m*m);}' *trim1.fq
	total 4594 avg=457.689813 stddev=75.785151
awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("total %d avg=%f stddev=%f\n",n,m,sq/n-m*m);}' *trim2.fq
	total 4594 avg=432.638659 stddev=375.542485
vi tag_primer_clipping_part2.sh --> clean and (re)formatting
check and edit clipped fastq files address
save and run
tag_primer_clipping_part2.sh
output:
format directory --> *_trim3.fq trimmed
awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("total %d avg=%f stddev=%f\n",n,m,sq/n-m*m);}' *trim3.fq
total 4594 avg=432.638659 stddev=375.542485
fastas directory --> *_f1.fasta, trim3 converted and error rate info
dereplicated directory --> *_dp.fasta, dereplicated by samples
my_samples_quality_file.qual --> fastq quality information
########################################################################
clustering, wrapped script:
vi clustering_swarm_complete.sh
edit: 
FINAL_FASTA="Name_for_global_derep_file.fas"
LENGTH=380 --> according to your expected amplicon lenght
check and edit input fastas --> the output from tag_primer_clipping_part2.sh
save and run
./clustering_swarm_complete.sh
outputs:
training_set_global_dp_1f_representatives.fas
training_set_global_dp_1f_representatives.uchime
training_set_global_dp.fas
training_set_global_dp.stats
training_set_global_dp.struct
training_set_global_dp.swarms
#############################################################################
taxonomic assignment through NCBI Blast best hit
#############################################################################
format references:
Download references from NCBI taxonomy
Download accession to taxid mapping file:
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
Download and extract taxdump
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
Download and extract Taxonkit
wget https://github.com/shenwei356/taxonkit/releases/download/v0.7.2/taxonkit_linux_amd64.tar.gz
https://bioinf.shenwei.me/taxonkit/tutorial/
vi format_NCBI2lineages.sh
edit:
INPUT: DATABASE="Xyleborus_genus.fasta"
OUTPUT: FORMATTED_DB="my_reference_lineage_formated.fasta"
change "my_reference" by the name of your choice, easily doing this:
sed 's/my_reference/Xyleborus/g' format_NCBI2lineages.sh > format_NCBI2lineages_Xyleborus.sh
this script needs 2 extra scripts to run: edit_lineage.pl and remove_dups.pl
edit the 2 internal scripts by the same way:
sed 's/my_reference/Xyleborus/g' edit_lineage.pl > edit_lineage_Xyleborus.pl
sed 's/my_reference/Xyleborus/g' remove_dups.pl > remove_dups_Xyleborus.pl
edit them inside format_NCBI2lineages_Xyleborus.sh
vi format_NCBI2lineages_Xyleborus.sh
save and run
./format_NCBI2lineages_Xyleborus.sh
output: Xyleborus_lineage_formated.fasta.uniq.fasta --> formatted references multifasta
>AB812619.1 Eukaryota|Arthropoda|Insecta|Coleoptera|Curculionidae|Xyleborus|Xyleborus+defensus
AACTTTATATTTTATCTTTGGGGCTTGAGCAGGAATAGTGGGAACTTCCTTAAGTGTATT
AATTCGAACAGAACTAGGAACACCAGGTAGCTTAATTGGAGATGATCAAATTTTCAATAC
running BLAST
vi Blast.sh
edit:
FASTA1="training_set_global_dp_1f_representatives.fas" --> from clustering
FASTA2="training_set_global_dp_2f_representatives.fas" --> header edited
LOCAL_DB="Xyleborus_lineage_formated.fasta.uniq.fasta" --> output from format_NCBI2lineages_Xyleborus.sh
remaining arguments, prefixes for blast output
output: training_set_Xyleborus_local_blast.tab
head training_set_Xyleborus_local_blast.tab
cd33aeee2e564736631f_96     99.762  Eukaryota|Arthropoda|Insecta|Coleoptera|Curculionidae|Xyleborus|Xyleborus+affinis gb|KP941297.1|  N/A
OTU		identity		lineage		accession 		
edit blast results
perl Blast_results_format.pl
Blast results file to edit:     training_set_Xyleborus_local_blast.tab
output: head Blast_results_formatted2OTUtable.tab
head Blast_results_formatted2OTUtable.tab
4ac2a3496a2f1cbb18bacd33aeee2e564736631f        96      99.762  Eukaryota|Arthropoda|Insecta|Coleoptera|Curculionidae|Xyleborus|Xyleborus+affinis KP941297.1      N/A
OTU	abundance	identity	lineage		accession
#############################################################################################
build OTU table
vi build_OTU_table.sh
edit:
FASTA="training_set_global_dp.fas" --> same as clustering
ASSIGNMENTS="Blast_results_formatted2OTUtable.tab" --> output from Blast_results_format.pl
QUALITY="my_samples_quality_file.qual" --> output from tag_primer_clipping_part2.sh
OTU_TABLE="training_set_OTU_table_complete.tab"
output: training_set_OTU_table_complete.tab
select fields for loading in Phyloseq:
vi taxa_assignment_table.pl
edit:
my $arq1 = "Blast_results_formatted2OTUtable.tab"; --> output from Blast_results_format.pl
open (NEW_FILE, '>>training_set_OTU_tax_assignments.txt'); --> name for the tax table
save and run
output: training_set_OTU_tax_assignments.txt
head training_set_OTU_tax_assignments.txt
amplicom        kingdom phylum  class   order   family  genus   specie  identity
4ac2a3496a2f1      Eukaryota       Arthropoda      Insecta   Coleoptera      Curculionidae   Xyleborus       affinis 99.762

cut the samples fields from the complete OTU table:
cat training_set_OTU_table_complete.tab | cut -f 4,14- | sed 's/_dp//g' > training_set_OTU_table2phyloseq.tab
