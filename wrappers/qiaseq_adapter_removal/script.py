###########################################
# wrapper for rule: miRNA_preprocessing
###########################################
import subprocess
from os.path import dirname
from os.path import basename
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, "wt")
f.write("\n##\n## RULE: qiaseq second adapter removal \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "gunzip -c " + str(snakemake.input) + " | fastx_collapser -Q" + str(snakemake.params.quality_base) + " | reformat.sh " + str(snakemake.params.extra) + " | gzip -c > " + snakemake.output.first_collapse 
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "cutadapt -j " + str(snakemake.threads) + " -a " + str(snakemake.params.adapter_seq) + " --times " + str(snakemake.params.remove_adap) + " \
    -e " + str(snakemake.params.error_rate) + " -O " + str(snakemake.params.min_overlap) + " -m " + str(snakemake.params.disc_short) + " \
    -o " + snakemake.output.trimmed + " --too-short-output " + snakemake.output.short + " --untrimmed-output " + snakemake.output.untrimmed + " \
    " + str(snakemake.output.first_collapse) + " | tee -a " + snakemake.output.text + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -d -c -p " + str(snakemake.threads) + " " + snakemake.output.trimmed + " | fastx_collapser | reformat.sh " + snakemake.params.extra + " > " + trimmed_seqs.replace(".fastq.gz", ".tmp")
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "python " + snakemake.params.script + " " + trimmed_seqs.replace(".fastq.gz", ".tmp") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p " + str(snakemake.threads) + " " + trimmed_seqs.replace(".fastq.gz", ".clean_collapsed.fastq") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "mv " + trimmed_seqs.replace(".fastq.gz", ".clean_collapsed.fastq.gz") + " " + str(snakemake.output.second_collapse) + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)
