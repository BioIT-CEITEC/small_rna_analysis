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

cutadapt_path = " ".join([dirname(fastqc_html) for fastqc_html in snakemake.input.first_cutadapt])

command = "multiqc -f -n " + snakemake.output.cutadapt + " " + cutadapt_path + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

trim_path = " ".join([dirname(fastqc_html) for fastqc_html in snakemake.input.first_trim])

command = "multiqc -f -n "  + snakemake.output.clean +  " " +  trim_path + " " + snakemake.params.clean + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "multiqc -f -n " + snakemake.output.untrim_short + " " + trim_path + " " + snakemake.params.others + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)
