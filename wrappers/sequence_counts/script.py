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
f.write("\n##\n## RULE: sequence counts \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "mkdir -p " + dirname(snakemake.output.summary) + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "mkdir -p " + str(snakemake.params.folder) + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "unzip -o " + dirname(snakemake.input.trimmed) + "/\"*fastqc.zip\"" + " -d " + str(snakemake.params.folder)+ " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "grep \"Total Sequences\" " + str(snakemake.params.folder) + "/" + basename(snakemake.input.trimmed).replace("_clean_collapsed_fastqc.html", "_*/*.txt") + " >> " + snakemake.output.summary 
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "rm -r " + str(snakemake.params.folder) + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)
