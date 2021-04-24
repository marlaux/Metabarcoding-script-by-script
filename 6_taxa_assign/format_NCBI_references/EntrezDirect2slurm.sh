###UNCOMMENT THE QUERY YOU WANT
###CHANGE ARGUMENTS AS DESCRIBED IN https://www.ncbi.nlm.nih.gov/books/NBK179288/ REFERENCE MANUAL
###TIPS:
#esearch -db nuccore --> searching nucletide sequences
#esearch -db nuccore -query "12S [TI] AND txid32443 [ORGN]" --> search for 12S in the title/description of the sequence from a taxid. 
#esearch -db nuccore -query "trnL [TI] AND Magnoliopsida [ORGN]" --> search for trnL in the title/description of the sequence from a taxa.
###the '| efetch -format abstract > ' extracts your sequences to file.
###keep the uppercase [ORGN] and [TI]
###the [TI] can be changed for [ALL], you can test what is better typing it in NCBI page
###for ITS, for example, you need to ask all options to get all ITS sequences:
#esearch -db nuccore -query "txid3398 [ORGN] AND (Internal transcribed space [TI] OR ITS1 [TI] OR ITS2 [TI])" 
###for COI it also happens: 
#esearch -db nuccore -query "txid1206794 [ORGN] AND (CO1 [TI] OR COI [TI] OR cytochrome oxidase I [TI])"
###you can filter:
  #| efilter -query "gene [FKEY]" or 
  #| efilter -query "cds [FKEY]" 
###you can read a file with accessions or taxids. For taxids, the syntax is:
#for i in `cat taxids.list`; do echo $i; esearch -db nuccore -query "$i [ORGN] AND 18S [TI]" | efetch -format fasta >> Zooplankton_18S; done
###for accessions, the syntax is:
#for i in `cat accession.list`; do echo $i; esearch -db nuccore -query "$i [ACC] AND rbcL [TI]" | efetch -format fasta >> Zooplankton_18S; done
###TRY DO KEEP/USE ONE OF THE FOLLOWING OPTIONS.
###RUN IN SLURM USING 
#sbatch run_format2lineage.slurm




#esearch -db pubmed -query "selective serotonin reuptake inhibitor" | efetch -format abstract > teste_pubmed_job.txt

#esearch -db nuccore -query "12S [TI] AND txid32443 [ORGN]" | efilter -location mitochondrion | efetch -format fasta > Teleostei_12S.fasta

#esearch -db nuccore -query "txid1206794 [ORGN] AND (CO1 [TI] OR COI [TI] OR cytochrome oxidase I [TI])" | efilter -query "gene [FKEY]" | efetch -format fasta > COI_Ecdysozoa.fasta

#esearch -db nuccore -query "txid1892249 [ORGN] OR txid1892255 [ORGN] OR txid1892252 [ORGN] OR txid1892254 [ORGN] NOT (environmental samples [ORGN])" | efilter -query "cds [FKEY]" | efetch -format fasta > Oscilla_families_selected_cds.fasta

#esearch -db nuccore -query "txid1301283 [ORGN] OR txid1161 [ORGN]" |   \
#  efilter -query "cds [FKEY]" |        \
#  efetch -format fasta > Nosto_Oscilla_gene.fasta

esearch -db protein -query "txid1301283 [ORGN] OR txid1161 [ORGN]" |    \
  efilter -source refseq | \
  efetch -format fasta > Nosto_Oscilla_protein.fasta

for i in `cat taxids.list`; do echo $i; esearch -db nuccore -query "$i [ORGN] AND 18S [TI]" | efetch -format fasta >> Zooplankton_18S; done

esearch -db nuccore -query "txid3398 [ORGN] AND (Internal transcribed space [TI] OR ITS1 [TI] OR ITS2 [TI])" | efetch -format fasta > Magnoliopsida_ITS.fasta
