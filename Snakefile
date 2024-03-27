import pandas as pd
import json
import os
from snakemake.utils import min_version

min_version("5.18.0")

configfile: "config.json"

GLOBAL_REF_PATH = config["globalResources"]
GLOBAL_TMPD_PATH = config["globalTmpdPath"]

os.makedirs(GLOBAL_TMPD_PATH, exist_ok=True)

##### BioRoot utilities #####
module BR:
    snakefile: gitlab("bioroots/bioroots_utilities", path="bioroots_utilities.smk",branch="master")
    config: config

use rule * from BR as other_*

#### Config processing #####

sample_tab = BR.load_sample()

config = BR.load_mirna()

tools = BR.load_tooldir()

config["tool_path"] = config["tooldir"] + "/miraligner/miraligner_3.5/miraligner.jar"

##### Adapter processing #####

if config["kit"] != "qiaseq":
    config["adapter_seq"] = "TGGAATTCTCGGGTGCCAAGG"
    config["adapter_2"] = ""
else:
    config["adapter_seq"] = "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
    config["adapter_2"] = "AACTGTAGGCACCATCAAT"



wildcard_constraints:
    sample = "|".join(sample_tab.sample_name)

#### Target rules ####
rule all:
    input: expand("results/qc_reports/{sample}.clean_collapsed_fastqc.html", sample = sample_tab.sample_name),
           expand("results/sequences_summary/{sample}.sequences_summary.txt", sample = sample_tab.sample_name),
           "results/qc_reports/multiqc/clean_trim/clean_trim_multiqc.html",
           expand("results/mapped_seqs/miraligner/{sample}.mirna", sample = sample_tab.sample_name),
           expand("results/mapped_seqs/rrna_stats/{sample}_rrna_mapping.txt", sample = sample_tab.sample_name),
           expand("results/qc_reports/{sample}/mirbase_canonical/{sample}.mirbase_canonical.tsv", sample = sample_tab.sample_name),
           expand("results/qc_reports/{sample}/mirbase_isomiRs/{sample}.mirbase_isomiRs.tsv", sample = sample_tab.sample_name)

#### Modules ####
include: "rules/preprocessing.smk"
include: "rules/mapping.smk"