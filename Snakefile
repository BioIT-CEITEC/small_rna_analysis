import pandas as pd
import json
import os
#from snakemake import min_version

#min_version("")

configfile: "config.json"

GLOBAL_REF_PATH = config["globalResources"]
GLOBAL_TMPD_PATH = config["globalTmpdPath"]

#### Config processing ####

sample_tab = pd.DataFrame.from_dict(config["samples"], orient = "index")

wildcard_constraints:
    sample = "|".join(sample_tab.sample_name),

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