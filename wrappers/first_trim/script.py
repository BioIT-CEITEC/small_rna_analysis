###########################################
# wrapper for rule: miRNA_preprocessing
###########################################

import subprocess
from os.path import dirname
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

if snakemake.params.kit != "truseq" or snakemake.params.kit != "nextflex_v4":
    flag = snakemake.params.extra + dirname(snakemake.output.trimmed) + "/" + snakemake.wildcards.sample + "_first_untrim.fastq.gz"
else:
    flag = ""

if snakemake.params.kit == "nextflex_v4":
    command = "cutadapt -a " + str(snakemake.params.adapter) + \
              " --cores 0 --discard-untrimmed --quality-cutoff 20 -o " + str(snakemake.output.trimmed).replace(".gz", "") + \
              " --too-short-output " + str(snakemake.output.short) + \
              " --minimum-length 16 " + str(snakemake.input) + " | tee -a " + str(snakemake.output.text) + " >> " + log_filename + " 2>&1"
    f = open(log_filename, "at")
    f.write("\n##\n## COMMAND: " + command + "\n")
    f.close()
    shell(command)

else:
    command = "cutadapt -a " + str(snakemake.params.adapter) + \
              " --times " + str(snakemake.params.remove_adap) + \
              " -e " + str(snakemake.params.error_rate) + \
              " -O " + str(snakemake.params.min_overlap) + \
              " -j " + str(snakemake.threads) + \
              " -m " + str(snakemake.params.disc_short) + \
              " --max-n " + str(snakemake.params.max_n) + \
              " -o " + str(snakemake.output.trimmed).replace(".gz", "") + str(flag) +\
              " --too-short-output " + snakemake.output.short + " " + str(snakemake.input) + " | tee -a " + str(snakemake.output.text) + " >> " + log_filename + " 2>&1"
    f = open(log_filename, "at")
    f.write("\n##\n## COMMAND: " + command + "\n")
    f.close()
    shell(command)

command = "fastq_quality_filter -v -q 20 -p 80 -z -i " + str(snakemake.output.trimmed).replace(".gz", "") + " -o " + str(snakemake.output.qual_filter)
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

command = "pigz -p 4 " + str(snakemake.output.trimmed).replace(".gz", "") + " >> " + log_filename + " 2>&1"
f = open(log_filename, "at")
f.write("\n##\n## COMMAND: " + command + "\n")
f.close()
shell(command)

