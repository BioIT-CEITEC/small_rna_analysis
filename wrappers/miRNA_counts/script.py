###########################################
# wrapper for rule: miRNA_preprocessing
###########################################
import subprocess
import os
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

current_directory = os.getcwd()
specific_folder = "results/mapped_seqs/miraligner"
working_folder = os.path.join(current_directory, specific_folder)

command = "Rscript "+os.path.abspath(os.path.dirname(__file__))+"/miraligner_new.R "+\
            working_folder + " >> " + log_filename + " 2>&1 "

f = open(log_filename, 'a+')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
