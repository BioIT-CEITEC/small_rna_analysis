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

command = "STAR --runMode alignReads --runThreadN 12 --genomeDir " + dirname(snakemake.input.rrna) + \
          " --readFilesCommand zcat" + \
          " --readFilesIn " + str(snakemake.input.clean) + \
          " --outFileNamePrefix " + dirname(snakemake.output.bam) + "/" + snakemake.wildcards.sample + ".rnar." + \
          " --outFilterMultimapNmax 5000" + \
          " --outFilterMatchNmin 15" + \
          " --outFilterMismatchNoverReadLmax 0.05" + \
          " --outFilterMultimapScoreRange 0" + \
          " --outFilterScoreMinOverLread 0" + \
          " --outFilterMismatchNmax 999" + \
          " --alignIntronMax 1"  + \
          " --alignIntronMin 2" + \
          " --outSAMheaderHD @HD VN:1.4 SO:coordinate" + \
          " --outSAMunmapped Within --outReadsUnmapped Fastx --outFilterType Normal " + \
          " --outSAMattributes All --twopassMode None " + \
          " --seedSearchStartLmax 10" + \
          " --winAnchorMultimapNmax 1000" + \
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
