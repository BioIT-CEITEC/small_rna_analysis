###########################################
# wrapper for rule: miRNA_preprocessing
###########################################
import subprocess
from os.path import dirname
from snakemake.shell import shell

shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, "wt")
f.write("\n##\n## RULE: miraligner \n##\n")
f.close()

version = str(subprocess.Popen("conda list", shell = True, stdout = subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, "at")
f.write("\n##\n## CONDA: " + version + "\n")
f.close()

command = "unpigz -c -p " + str(snakemake.threads) + " " + str(snakemake.input.unmapped) + " > " + str(snakemake.input.unmapped).replace(".gz", "")
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "java -jar -Xms512m -Xmx8g " + str(snakemake.params.miraligner) + " -freq -sub " + str(snakemake.params.mir_mismatch) + \
    " -trim " + str(snakemake.params.mir_trim) + " -add " + str(snakemake.params.mir_add) + " -minl " + str(snakemake.params.mir_minl) + \
    " -s " + str(snakemake.params.species) + " -i " + str(snakemake.input.unmapped).replace(".gz", "") + " -db " + dirname(snakemake.input.miraligner_db) + \
    " -o " + str(snakemake.output.mirna).replace(".mirna", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "cut -f2 " + str(snakemake.output.mirna) + " | sort | uniq > " + snakemake.wildcards.sample + "_mapped.names 2>> " + log_filename + " 2>&1 " 
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "sed -i 's/^/@/' " + snakemake.wildcards.sample + "_mapped.names >> " + log_filename + " 2>&1 " 
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "awk 'NR % 4 == 1' " + str(snakemake.input.unmapped).replace(".gz", "") + " > " + snakemake.wildcards.sample + "_all.names 2>> " + log_filename + " 2>&1 "
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "grep -v -w -F -f " + snakemake.wildcards.sample + "_mapped.names " + snakemake.wildcards.sample + "_all.names > " + snakemake.wildcards.sample + "_nomap.names 2>> " + log_filename + " 2>&1 "
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "grep --no-group-separator -A 3 -w -F -f " + snakemake.wildcards.sample + "_nomap.names " + str(snakemake.input.unmapped).replace(".gz", "") + " > " + str(snakemake.output.unmapped).replace(".gz", "") + " 2>> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p " + str(snakemake.threads) + " " + str(snakemake.output.unmapped).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "rm " + snakemake.wildcards.sample + "_mapped.names " + snakemake.wildcards.sample + "_all.names " + snakemake.wildcards.sample + "_nomap.names >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)