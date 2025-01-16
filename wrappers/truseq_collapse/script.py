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
f.write("\n##\n## RULE: collapse truseq \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "pigz -d -c -p " + str(snakemake.threads) + " " + str(snakemake.input.trimmed) + " | fastx_collapser | reformat.sh qfake=40 in=stdin.fa out=stdout.fq > " + str(snakemake.input.trimmed).replace(".fastq.gz", ".tmp")
f = open(log_filename, "at")
f.write("\n#\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "python resources/change_header_format.py " + str(snakemake.input.trimmed).replace(".fastq.gz", ".tmp") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p " + str(snakemake.threads) + " " + str(snakemake.input.trimmed).replace(".fastq.gz", ".clean_collapsed.fastq")
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "mv " + str(snakemake.input.trimmed).replace(".fastq.gz", ".clean_collapsed.fastq.gz") + " " + snakemake.output.cleaned + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)