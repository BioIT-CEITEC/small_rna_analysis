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

command = "unpigz -c -p " + str(snakemake.threads) + " " + str(snakemake.input.unmapped) + " > " + str(snakemake.input.unmapped).replace(".gz", "") + " 2>> " + log_filename + " 2>&1 "
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "java -jar resources/miraligner_3.5/miraligner.jar -freq -sub " + str(snakemake.params.mir_mismatch) + \
    " -trim " + str(snakemake.params.mir_trim) + " -add " + str(snakemake.params.mir_add) + " -minl " + str(snakemake.params.mir_minl) + \
    " -s " + str(snakemake.params.species) + " -i " + str(snakemake.input.unmapped).replace(".gz", "") + " -db " + str(snakemake.params.database) + \
    " -o " + str(snakemake.output.mirna).replace(".mirna", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "cut -f2 " + str(snakemake.output.mirna) + " | sort | uniq > mapped.names 2>> " + log_filename + " 2>&1 " 
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "sed -i 's/^/@/' mapped.names >> " + log_filename + " 2>&1 " 
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "awk 'NR % 4 == 1' " + str(snakemake.input.unmapped).replace(".gz", "") + " > all.names 2>> " + log_filename + " 2>&1 "
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "grep -v -w -F -f mapped.names all.names > nomap.names 2>> " + log_filename + " 2>&1 "
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "grep --no-group-separator -A 3 -w -F -f nomap.names " + str(snakemake.input.unmapped).replace(".gz", "") + " > " + str(snakemake.output.unmapped).replace(".gz", "") + " 2>> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p " + str(snakemake.threads) + " " + str(snakemake.output.unmapped).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "rm mapped.names all.names nomap.names >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)