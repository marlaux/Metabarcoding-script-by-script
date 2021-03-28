# Setup environment
setwd("C:/Users/user/user/METAPIPE/8_filter_table_phyloseq/")
library(phyloseq)
library(ggplot2)
library(ape)
library(vegan)
library(dplyr)
library(reshape2)
library(gridExtra)
library(xfun)
library("RColorBrewer")
###################################################################################################
#1a. load the OTU table (OTU by sample abundance)
otu_table <- read.table("my_training_set_OTU_table_complete_f1_cut2phyloseq.tab", header=TRUE, row.names=1)
#1b. convert table to matrix
otu_table <- as.matrix(otu_table)
#2a. load the taxa assignments table (OTU - lineage - taxa by best hit)
taxonomy <- read.csv("my_training_set_OTU_tax_assignments.txt", sep = "\t", row.names = 1, check.names = FALSE)
#2b. convert table to matrix
taxonomy <- as.matrix(taxonomy)
#load the metadata, a tab delimited text file with the SampleID (mandatory) in the first column and following 
#columns describing important features from your data. The format must be like this:
#SampleID	SampleName	season	Replicate
#AMa_I	Amazon_W_I	Winter  Amazon_W
#AMa_II	Amazon_W_II	Winter	Amazon_W
#AMb_I	Amazon_S_I	Summer	Amazon_S
#AMb_II	Amazon_S_II	Summer	Amazon_S
metadata <- read.table("my_training_set_mapping_file2.txt", header=TRUE, row.names = 1)
meta <- as.matrix(metadata)
#tables conversion to variables according to Phyloseq functions
OTU <- otu_table(otu_table, taxa_are_rows = TRUE)
TAX <- tax_table(taxonomy)
META <- sample_data(metadata)
#Combine the new three data variables into a Phyloseq object, allowing the concomitant quantitative 
#and taxonomical data exploration, along with to any descriptive variable present in metadata file.
merged <- phyloseq(OTU, TAX, META)
#create a random phylogenetic tree
random_tree = rtree(ntaxa(merged), rooted=TRUE, tip.label=taxa_names(merged))
#create the final phyloseq object merging all 4 main components, OTU, TAX, META and random_tree.
data <- phyloseq(OTU, TAX, META, random_tree)
data 
##################################################################################
#Basic data checking
####################
sample_names(data)
ntaxa(data)
nsamples(data)
sum(sample_sums(data))
tax_table(data)[,"order"] %>% unique %>% na.exclude #number of distinct orders detected
tax_table(data)[,"genus"] %>% unique %>% na.exclude #number of distinct genera detected
rank_names(data)
taxa_names(data)[1:10]
sample_variables(data)
tax_table(data)[1:5, 1:4]
rare = rarefy_even_depth(data, rngseed=1, replace=F)
rare <- prune_taxa(taxa_sums(rare) > 0, rare)
rarecurve(t(otu_table(rare)), 10, col=col, label=FALSE, step=500, cex=0.5, xlab = "sample size")
phy_tree(data)
myTaxa = names(sort(taxa_sums(data), decreasing = TRUE)[1:10])
ex1 = prune_taxa(myTaxa, data)
plot(phy_tree(ex1), show.node.label = TRUE)
plot_tree(data, label.tips = "order", size = "Abundance", color = "Field")
plot_richness(data, x = "Replicate", color = "Field", measures = c("Observed", "Shannon")) + geom_boxplot()
################################################################################
#remove blanks
####################
data_cl <- subset_samples(data, Replicate != "blank")
data_cl <- prune_taxa(taxa_sums(data_cl) > 0, data_cl) #this command removes empty OTUs resulting from the subsetting
#####################################################################
#keep OTUs with frequency >5% , for example 5% of 100 samples is 5:
####################
data_f1 <- filter_taxa(data_cl, function(x){sum(x > 0) > 5}, prune = TRUE)
############################################################################
#remove low abundance OTUs (you define your threshold. I like to use < 10% of the dataset median)
####################
data_f2 = filter_taxa(data_f1, function(x) sum(x) > 8, TRUE)
##############################################################################
#Subset Arthropoda
####################
data_Arthr <- subset_taxa(data_f2, phylum == "Arthropoda")
data_Arthr <- prune_taxa(taxa_sums(data_Arthr) > 0, data_Arthr)
##############################################################################
#Subset Biome
####################
data_am <- subset_samples(data_f2, biome == "Amazon")
data_am <- prune_taxa(taxa_sums(data_am) > 0, data_am)
############################################################################
#Top50 OTUs from the whole dataset, without trimming, only remove controls or blanks
####################
topN <- 50
most_abundant_taxa = sort(taxa_sums(data_cl), TRUE)[1:topN]
top <- prune_taxa(names(most_abundant_taxa), data_cl)
top_OTUs <- data.frame(taxa_sums(top))
write.table(top_50_OTUs, file='data_top50.txt')
colnames(top_OTUs) <- "Sample_TotalSeqs"
top_OTUs$sample <- row.names(top_OTUs)
top_OTUs <- arrange(top_OTUs, Sample_TotalSeqs)
top_OTUs
ggplot(top_OTUs,aes(x=reorder(sample, -Sample_TotalSeqs), y = Sample_TotalSeqs)) + 
  geom_bar(stat="identity",colour="black",fill="cornflowerblue")  +
  xlab("OTU Rank") + ylab("Top 50 most abundant OTUs") +
  scale_x_discrete(expand = c(0,0)) + 
  scale_y_continuous(expand = c(0,0)) + theme_classic() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())
################################################################################
#create taxonomic barplot with relative abundance
#first choose the taxonomic rank. tax_glom function merges species below the branch chosen, e.i. order:
#################################################
data_ord <- data %>%
  tax_glom(taxrank = "specie") %>%                     
  transform_sample_counts(function(x) {x/sum(x)} ) %>%  #transformation to relative abundance
  psmelt() %>%                                         
  filter(Abundance > 0.01) %>%            #if you do not want any filter, just comment the line             
  arrange(specie)
display.brewer.all()
colourCount = 8
sample_data(data_ord)
getPalette = colorRampPalette(brewer.pal(12, "Paired"))
ggplot(data_ord, aes(x = Sample, y = Abundance, fill = specie)) + 
  geom_bar(stat = "identity") +
  scale_fill_manual(values = getPalette(colourCount)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Relative Abundance specie >1% \n") 
  #coord_polar("y", start=0) 
