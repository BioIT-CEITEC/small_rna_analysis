import sys
import os

fin = open(sys.argv[1],"r")

fout_name = os.path.splitext(sys.argv[1])[0]

fout = open(fout_name + ".clean_collapsed.fastq", "w")

for line in fin:
	if "@" in line:
		l1 = line.split("-")
		new_header = "@seq_" + l1[0].strip("@") + "_x" + l1[1]
		fout.write(new_header)
	else:
		fout.write(line)
