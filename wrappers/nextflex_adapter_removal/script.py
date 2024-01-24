###########################################
# wrapper for rule: miRNA_preprocessing
###########################################
import subprocess
from os.path import dirname
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, "wt")
f.write("\n##\n## RULE: second trim nextflex_v3 and collapse \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "cutadapt -u " + str(snakemake.params.left_trim) + \
          " -u " + str(snakemake.params.right_trim) + \
          " -o " + str(snakemake.output.trimmed) + " " + str(snakemake.input) + \
          " | tee -a " + str(snakemake.output.text) + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -d -c -p " + str(snakemake.threads) + " " + snakemake.output.trimmed + " | fastx_collapser | reformat.sh " + snakemake.params.extra + " > " + dirname(snakemake.output.trimmed) + "/" + snakemake.wildcards.sample + ".second_trim.tmp"
f = open(log_filename, "at")
f.write("\n#\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "python " + snakemake.params.script + " " + dirname(snakemake.output.trimmed) + "/" + snakemake.wildcards.sample + ".second_trim.tmp >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p " + str(snakemake.threads) + " " + dirname(snakemake.output.trimmed) + "/" + snakemake.wildcards.sample + ".second_trim.clean_collapsed.fastq"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "mv " + dirname(snakemake.output.trimmed) + "/" + snakemake.wildcards.sample + ".second_trim.clean_collapsed.fastq.gz" + snakemake.output.cleaned + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)