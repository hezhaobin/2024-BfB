# title: prepare gene ID and DGE list for goseq
# author: Bin He
# date: 2022-11-04

require(tidyverse)
# open input file
dat <- read_tsv("DESeq2-result-with-NA.txt", 
                col_names = c("GeneID","Base mean","log2(FC)","StdErr","Wald-Stats","P-value","P-adj","Chromosome","Start","End","Strand","Feature","Gene name"), 
                col_types = cols())
out <- dat %>%  mutate(GeneID = toupper(GeneID), DEG = ifelse(is.na(`P-adj`), FALSE, `P-adj` < 0.05), .keep = "none")
write_tsv(out, file = "Gene IDs and differential expression.tabular", col_names = FALSE)
