######################################
# wrapper for rule: preprocess
######################################
import subprocess
import os
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'wt')
f.write("\n##\n## RULE: raw_fastq_qc \n##\n")
f.close()

# version = str(subprocess.Popen("conda list ", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
# f = open(log_filename, 'at')
# f.write("## CONDA: "+version+"\n")
# f.close()

if snakemake.params.library_type == "qiaseq":

elif snakemake.params.library_type == "nextflow":

else:

#
#
#
# if int(snakemake.params.trim_left1) > 0 or int(snakemake.params.trim_right1) > 0:
#     extra_flags_seqtk =  " -b "+str(snakemake.params.trim_left1) if int(snakemake.params.trim_left1) > 0 else ""
#     extra_flags_seqtk += " -e "+str(snakemake.params.trim_right1) if int(snakemake.params.trim_right1) > 0 else ""
#
#     command = "seqtk trimfq "+extra_flags_seqtk+" "+fastq_r1+" | gzip -c > "+fastq_r1.replace(".gz",".trim.gz")
#     f = open(log_filename, 'at')
#     f.write("## COMMAND: "+command+"\n")
#     f.close()
#     shell(command)
#
# if is_paired:
#     if int(snakemake.params.trim_left2) > 0 or int(snakemake.params.trim_right2) > 0:
#         extra_flags_seqtk =  " -b "+str(snakemake.params.trim_left2) if int(snakemake.params.trim_left2) > 0 else ""
#         extra_flags_seqtk += " -e "+str(snakemake.params.trim_right2) if int(snakemake.params.trim_right2) > 0 else ""
#
#         command = "seqtk trimfq "+extra_flags_seqtk+" "+fastq_r2+" | gzip -c > "+fastq_r2.replace(".gz",".trim.gz")
#         f = open(log_filename, 'at')
#         f.write("## COMMAND: "+command+"\n")
#         f.close()
#         shell(command)
#
# simpleClipThreshold = 10
# # TODO: check for better settings (see: http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf starting at page 5, or http://www.usadellab.org/cms/?page=trimmomatic)


trim_left = "" # HARD DEFAULT, as this is no longer in use, but might be in the future
#trim_left = "" if snakemake.params.trim_left == "" else "HEADCROP:"+snakemake.params.trim_left

command = "mkdir -p " + os.path.dirname(snakemake.params.trim_stats)
f = open(log_filename, 'at')
f.write("## COMMAND: " + command + "\n")
f.close()
shell(command)

if is_paired:
    if snakemake.params.adaptors != "":
        adaptors = snakemake.params.adaptors.split(",")
        with open(os.path.dirname(fastq_c2) + "/adapters.fa", "w") as adaptor_file:
            for i, adaptor in enumerate(adaptors):
                if adaptor.split("-")[0] == "1":
                    adaptor_file.write(">adapt" + str(i) + "/1\n")
                    adaptor_file.write(adaptor.split("-")[1] + "\n")
                elif adaptor.split("-")[0] == "2":
                    adaptor_file.write(">adapt" + str(i) + "/2\n")
                    adaptor_file.write(adaptor.split("-")[1] + "\n")
                if (len(adaptor.split("-")[1]) < 20):
                    simpleClipThreshold = min(len(adaptor.split("-")[1]) // 2, simpleClipThreshold)

        adaptors = "ILLUMINACLIP:" + os.path.dirname(fastq_c2) + "/adapters.fa:2:30:" + str(simpleClipThreshold) + ":3:true"
    else:
        adaptors = ""

    input_r1 = fastq_r1.replace(".gz",".trim.gz") if int(snakemake.params.trim_left1) > 0 or int(snakemake.params.trim_right1) > 0 else fastq_r1
    input_r2 = fastq_r2.replace(".gz",".trim.gz") if int(snakemake.params.trim_left2) > 0 or int(snakemake.params.trim_right2) > 0 else fastq_r2

    command = "mkdir -p " + os.path.dirname(snakemake.params.r1u)
    f = open(log_filename, 'at')
    f.write("## COMMAND: " + command + "\n")
    f.close()
    shell(command)

    command = "trimmomatic PE -threads "+str(snakemake.threads)+" "+snakemake.params.phred+" "+input_r1+" "+input_r2+" "+fastq_c1+"\
        "+snakemake.params.r1u+" "+fastq_c2+" "+snakemake.params.r2u+" CROP:"+str(snakemake.params.crop)+" LEADING:"+str(snakemake.params.leading)+"\
        TRAILING:"+str(snakemake.params.trailing)+" SLIDINGWINDOW:"+str(snakemake.params.slid_w_1)+":"+str(snakemake.params.slid_w_2)+" "+adaptors+" MINLEN:"+str(snakemake.params.minlen)+"\
        "+trim_left+" -Xmx"+str(snakemake.resources.mem)+"g >> "+snakemake.params.trim_stats+" 2>&1 "

    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command+"\n")
    f.close()
    shell(command)


else:
    if snakemake.params.adaptors != "":
        adaptors = snakemake.params.adaptors.split(",")
        with open(os.path.dirname(fastq_c1) + "/adapters.fa", "w") as adaptor_file:
            for i, adaptor in enumerate(adaptors):
                if adaptor.split("-")[0] == "1":
                    adaptor_file.write(">adapt" + str(i) + "\n")
                    adaptor_file.write(adaptor.split("-")[1] + "\n")
                    if (len(adaptor.split("-")[1]) < 20):
                        simpleClipThreshold = min(len(adaptor.split("-")[1]) // 2, simpleClipThreshold)
                else:
                    adaptor_file.write(">adapt" + str(i) + "\n")
                    adaptor_file.write(adaptor + "\n")
                    if (len(adaptor) < 20):
                        simpleClipThreshold = min(len(adaptor) // 2, simpleClipThreshold)

        adaptors = "ILLUMINACLIP:" + os.path.dirname(fastq_c1) + "/adapters.fa:2:30:" + str(simpleClipThreshold) + ":3"
    else:
        adaptors = ""

    input_r1 = fastq_r1.replace(".gz", ".trim.gz") if int(snakemake.params.trim_left1) > 0 or int(snakemake.params.trim_right1) > 0 else fastq_r1

    command = "trimmomatic SE -threads " + str(snakemake.threads) + " " + snakemake.params.phred + " " + input_r1 + " " + fastq_c1 + "\
        " + adaptors + " CROP:" + str(snakemake.params.crop) + " LEADING:" + str(snakemake.params.leading) + "\
        TRAILING:" + str(snakemake.params.trailing) + " SLIDINGWINDOW:" + str(snakemake.params.slid_w_1) + ":" + str(snakemake.params.slid_w_2) + " MINLEN:" + str(snakemake.params.minlen) + "\
        " + trim_left + " -Xmx" + str(snakemake.resources.mem) + "g >> " + snakemake.params.trim_stats + " 2>&1 "

    f = open(log_filename, 'at')
    f.write("## COMMAND: " + command + "\n")
    f.close()
    shell(command)

if int(snakemake.params.trim_left1) > 0 or int(snakemake.params.trim_right1) > 0:
  command = "rm "+fastq_r1.replace(".gz",".trim.gz")+" >> "+log_filename+" 2>&1 "
  f = open(log_filename, 'at')
  f.write("## COMMAND: "+command+"\n")
  f.close()
  shell(command)

if is_paired:
    if int(snakemake.params.trim_left2) > 0 or int(snakemake.params.trim_right2) > 0:
      command = "rm "+fastq_r2.replace(".gz",".trim.gz")+" >> "+log_filename+" 2>&1 "
      f = open(log_filename, 'at')
      f.write("## COMMAND: "+command+"\n")
      f.close()
      shell(command)
