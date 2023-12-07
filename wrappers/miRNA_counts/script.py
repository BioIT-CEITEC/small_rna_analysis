###########################################
# wrapper for rule: miRNA_preprocessing
###########################################
import subprocess
import os
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

current_directory = os.getcwd()
specific_folder = "results/mapped_seqs/miraligner"
working_folder = os.path.join(current_directory, specific_folder)

final_folder = "results/"
target_folder = os.path.join(current_directory, final_folder)

command = "Rscript " + str(snakemake.params.script_counts) + " " + working_folder + " " + target_folder + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)
