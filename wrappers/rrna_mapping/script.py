###########################################
# wrapper for rule: miRNA_preprocessing
###########################################
import subprocess
from os.path import dirname
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, "wt")
f.write("\n##\n## RULE: merge first qc \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "mkdir -p " + dirname(snakemake.output.mapping_stats)
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "STAR --runMode alignReads --runThreadN " + str(snakemake.params.nthreads) + " --genomeDir " + snakemake.input.rrna[0] + \
          " --readFilesCommand zcat" + \
          " --readFilesIn " + str(snakemake.input.clean) + \
          " --outFileNamePrefix " + dirname(snakemake.output.bam) + "/" + snakemake.wildcards.sample + ".rnar." + \
          " --outFilterMultimapNmax " + str(snakemake.params.max_multimap) + \
          " --outFilterMatchNmin " + str(snakemake.params.min_multimap) + \
          " --outFilterMismatchNoverReadLmax " + str(snakemake.params.filter_mismatch) + \
          " --outFilterMultimapScoreRange " + str(snakemake.params.score_range) + \
          " --outFilterScoreMinOverLread " + str(snakemake.params.min_over) + \
          " --outFilterMismatchNmax " + str(snakemake.params.filtermax_mismatch) + \
          " --alignIntronMax " + str(snakemake.params.intron_max) + \
          " --alignIntronMin " + str(snakemake.params.intron_min) + \
          " --outSAMheaderHD @HD VN:1.4 SO:coordinate" + \
          " --outSAMunmapped Within --outReadsUnmapped Fastx --outFilterType Normal " + \
          " --outSAMattributes All --twopassMode None " + \
          " --seedSearchStartLmax " + str(snakemake.params.seed_search) + \
          " --winAnchorMultimapNmax " + str(snakemake.params.anchor_multimap) + \
          " --outMultimapperOrder Random --outSAMtype BAM Unsorted " + \
          " --alignEndsType EndToEnd  >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

#command = "mv " + dirname(snakemake.input.clean) + "/*.rnar.* " + dirname(snakemake.output.bam) + " >> " + log_filename + " 2>&1"
#f = open(log_filename, "at")
#f.write("\n##\n## COMMAND: " + command + "\n")
#f.close()
#shell(command)

command = "samtools view " + snakemake.output.bam + " | grep -w \"NH:i:1\" - | cut -f1 - | cut -d\"_\" -f3 - | sed 's/x//g' | awk '{{ sum += $1 }} END {{ print sum }}' >> " + snakemake.output.mapping_stats
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "samtools view " + snakemake.output.bam + " | grep -v \"NH:i:1\" - | grep -v \"NH:i:0\" - | cut -f1 - | sort | uniq | cut -d\"_\" -f3 - | sed 's/x//g' | awk '{{ sum += $1 }} END {{ print sum }}' >> " + snakemake.output.mapping_stats
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "mv " + dirname(snakemake.output.bam) + "/" + snakemake.wildcards.sample + ".rnar.Unmapped.out.mate1 " + str(snakemake.output.unmapped).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "sed -i 's/ 0:N: //g' " + str(snakemake.output.unmapped).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "gzip " + str(snakemake.output.unmapped).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)
