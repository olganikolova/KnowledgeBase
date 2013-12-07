###############################################
#
# Re-format knowledge-base
# Annotate therapeutic context for CCLE & Sanger
#
# Author: Olga Nikolova
# E-mail: olga.nikolova@gmail.com
###############################################

#!/bin/bash 

# STEP 1: Convert xcel file into .tsv files
# each cheet (cancer type) into a separate file
echo "STEP 1: Convert xcel file into .tsv files"
R --no-save <xls2tsv.R

# STEP 2: Re-format each .tsv file into a maf-like format
# one line per gene-variant & ther. context
echo "STEP 2: Re-format each .tsv file into a maf-like format"
cd /home/onikolov/projects/gold_standard/data/
for file in *.knb.tsv; do
  echo $file
  perl /home/onikolov/projects/gold_standard/code/convert.pl $file
done; # end_for_file
cd  ../

# STEP 3: Combine all files short of the headers 
echo "STEP 3: Combine all files short of the headers "
mkdir /home/onikolov/projects/gold_standard/results

mv /home/onikolov/projects/gold_standard/data/*.maf.tsv /home/onikolov/projects/gold_standard/results

tail -q -n +2 /home/onikolov/projects/gold_standard/results/*.maf.tsv >/home/onikolov/projects/gold_standard/results/combined.maf.tsv

# STEP 4: Upload to Synapse
echo "STEP 4: Upload to Synapse"
synapse add /home/onikolov/projects/gold_standard/results/combined.maf.tsv \
-parentId syn2276557 \
-description "MAF-like format for the Knowledge Database - all cancer types, one line per gene variant" \
-name KnowledgeBase.maf.tsv

# STEP 5: Merge Knowledgebase with CCLE and Sanger (infer
# annotations for drugs in CCLE and Sanger from Knowledgebase)
echo "STEP 5: Merge Knowledgebase with CCLE and Sanger"
perl  /home/onikolov/projects/gold_standard/code/merge.pl /home/onikolov/projects/gold_standard/data/Key2Merge_CCLE_Sanger_Kdb.tsv /home/onikolov/projects/gold_standard/results/combined.maf.tsv

# STEP 6: Upload final result to Synapse
echo "STEP 6: Upload final result to Synapse"
synapse add /home/onikolov/projects/gold_standard/results/Merged_CCLE_Sanger_Kdb.maf.tsv \
-parentId syn2276557 \
-description "MAF-like format for the Knowledge Database merged with CCLE and Sanger - all cancer types, one line per gene variant" \
-name Merged_CCLE_Sanger_KnowledgeBase.maf.tsv
