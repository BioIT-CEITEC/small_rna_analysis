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
f.write("\n##\n## RULE: first trim \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = command = "cutadapt -a " + str(snakemake.params.adapter) + " --times " + str(snakemake.params.remove_adap) + " -e " + str(snakemake.params.error_rate) + " -O " + str(snakemake.params.min_overlap) + " -j " + str(snakemake.threads) + " \
-m " + str(snakemake.params.disc_short) + " --max-n " + str(snakemake.params.max_n) + " -o " + str(snakemake.output.trimmed).replace(".gz", "") + " --untrimmed-output " + snakemake.output.untrimmed + " \
--too-short-output " + snakemake.output.short + " " + str(snakemake.input) + " | tee -a " + snakemake.output.text + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p 4 " + dirname(snakemake.output.trimmed) + "/" + basename(snakemake.output.trimmed).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)
