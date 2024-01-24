###########################################
# wrapper for rule: miRNA_preprocessing
###########################################

import subprocess
from os.path import dirname
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, "wt")
f.write("\n##\n## RULE: first quality control \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "fastqc --outdir " + dirname(snakemake.output.trim) + " --format " + str(snakemake.params.formats) + \
          " --threads " + str(snakemake.threads) + " " + dirname(snakemake.input.clean) + "/" + snakemake.wildcards.sample + ".*.fastq.gz  >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

