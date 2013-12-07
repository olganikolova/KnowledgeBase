###############################################
#
# .xls workbook with multiple sheets to .tsv files per cancer type
# .xls key file for merging into .tsv file
#
# Author: Olga Nikolova
# E-mail: olga.nikolova@gmail.com
###############################################
library(synapseClient)
require(XLConnect)
require(gdata)

#Read your workbook 
obj <- synGet("syn2318980")
wb<-loadWorkbook(obj@filePath)
#wb<-loadWorkbook("/home/onikolov/projects/gold_standard/data/Knowledge_database_v1.1.xls")

#Save each sheet's name as a vector
# Only included the first 23 sheets/cancer types
# Would change if other cancer types are considered
lp<-getSheets(wb)[1:23] 
dat <- readWorksheet(wb, sheet = lp)
lapply(1:length(lp), function(idx){
  d<-dat[[idx]]
  filename=paste("/home/onikolov/projects/gold_standard/data/", gsub(' ', '', lp[idx]), ".knb.tsv", sep="")
  write.table(d, file=filename, sep="\t", row.names=FALSE)
})

obj <- synGet("syn2318952")
d<-read.xls(obj@filePath) 
write.table(d, file="/home/onikolov/projects/gold_standard/data/Key2Merge_CCLE_Sanger_Kdb.tsv", 
            sep="\t", row.names=FALSE)
