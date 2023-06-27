######################################
# wrapper for rule: raw_fastq_qc
######################################
import subprocess
from os.path import dirname
from os.path import basename
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: raw_fastq_qc \n##\n")
f.close()

version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## CONDA: "+version+"\n")
f.close()

command = "mkdir -p " + dirname(snakemake.output.html) + " >> "+log_filename+" 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

raw_tag_input_fastq = dirname(snakemake.input.raw_fastq) + "/" + snakemake.wildcards.sample + "_" + snakemake.wildcards.read_pair_tag + "_raw.fastq.gz"

command = "cp " + snakemake.input.raw_fastq + " " + raw_tag_input_fastq + " >> "+log_filename+" 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "fastqc -o " + dirname(snakemake.output.html) + " "+snakemake.params.extra+" --threads "+str(snakemake.threads)+" "+raw_tag_input_fastq+" >> "+log_filename+" 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "rm " + raw_tag_input_fastq + " >> "+log_filename+" 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv " + dirname(snakemake.output.html) + "/" + basename(raw_tag_input_fastq).replace(".fastq.gz","_fastqc.html") + " " + snakemake.output.html
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

if snakemake.wildcards.read_pair_tag == "":
    zip_out_basename = "SE_fastqc.zip"
else:
    zip_out_basename = snakemake.wildcards.read_pair_tag.replace("_","") + "_fastqc.zip"

command = "mv " + dirname(snakemake.output.html) + "/" + basename(raw_tag_input_fastq).replace(".fastq.gz","_fastqc.zip") + " " + dirname(snakemake.output.html) + "/" + zip_out_basename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

# command = ' sed -r -i "s:<h2>[ ]*Summary[ ]*<\/h2><ul>:&<li><b>Return to <a href=\'../'+snakemake.params.lib_name+'.final_report.html\'>start page<\/a><\/b><\/li>:" '+snakemake.output.html
# f = open(log_filename, 'at')
# f.write("## COMMAND: "+command+"\n")
# f.close()
# shell(command)
