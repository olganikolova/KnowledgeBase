###############################################
#
# Re-format knowledge-base
# Annotate therapeutic context for CCLE & Sanger
#
# Author: Olga Nikolova
# E-mail: olga.nikolova@gmail.com
###############################################

#!/bin/bash 

# Step 1: Convert xcel file into .tsv files
# each cheet (cancer type) into a separate file
echo "Step 1: Convert xcel file into .tsv files"
R --no-save <xls2tsv.R

# Step 2: Re-format each .tsv file into a maf-like format
# one line per gene-variant & ther. context
echo "Step 2: Re-format each .tsv file into a maf-like format"
cd /home/onikolov/projects/gold_standard/data/
for file in *.knb.tsv; do
  echo $file
  perl /home/onikolov/projects/gold_standard/code/convert.pl $file
done; # end_for_file
cd  /home/onikolov/projects/gold_standard

# Step 3: Combine all files short of the headers 
echo "Step 3: Combine all files short of the headers "
mkdir /home/onikolov/projects/gold_standard/results

mv /home/onikolov/projects/gold_standard/data/*.maf.tsv /home/onikolov/projects/gold_standard/results

tail -q -n +2 /home/onikolov/projects/gold_standard/results/*.maf.tsv >/home/onikolov/projects/gold_standard/results/combined.maf.tsv

# Step 4: Upload to Synapse
echo "Step 4: Upload to Synapse"
synapse add /home/onikolov/projects/gold_standard/results/combined.maf.tsv \
-parentId syn2276557 \
-description "MAF-like format for the Knowledge Database - all cancer types, one line per gene variant" \
-name KnowledgeBase.maf.tsv
