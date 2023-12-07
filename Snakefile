import pandas as pd
import json
import os
from snakemake import min_version

min_version("5.18.0")

configfile: "config.json"

GLOBAL_REF_PATH = config["globalResources"]
GLOBAL_TMPD_PATH = config["globalTmpdPath"]


f = open(os.path.join(GLOBAL_REF_PATH,"reference_info","mirna_reference.json"),)
reference_dict = json.load(f)
f.close()
config["species_name"] = [organism_name for organism_name in reference_dict.keys() if isinstance(reference_dict[organism_name],dict) and config["reference"] in reference_dict[organism_name].keys()][0]
config["organism"] = config["species_name"].split(" (")[0].lower().replace(" ","_")
if len(config["species_name"].split(" (")) > 1:
    config["species"] = config["species_name"].split(" (")[1].replace(")","")

assembly_release = 
config["assembly"] = config["reference"].split("_")[0]
config["species"] = config["reference"].split("_")[1]

#### Config processing ####

reference_directory = os.path.join(GLOBAL_REF_PATH,"references",config["organism"],config["assembly"])

#### Samples ####
sample_tab = pd.DataFrame.from_dict(config["samples"], orient = "index")

wildcard_constraints:
    sample = "|".join(sample_tab.sample_name),

#### Target rules ####
rule all:
    input: expand("results/qc_reports/{sample}_clean_collapsed_fastqc.html", sample = sample_tab.sample_name),
           expand("results/sequences_summary/sequences_summary.txt", sample = sample_tab.sample_name),
           "results/qc_reports/multiqc/clean_trim/clean_trim_multiqc.html",
           expand("results/mapped_seqs/miraligner/{sample}.mirna", sample = sample_tab.sample_name),
           expand("results/mapped_seqs/rrna_stats/{sample}_rrna_mapping.txt", sample = sample_tab.sample_name),
           "results/counts_tables/mirna.mirbase_canonical.tsv",
           "results/counts_tables/mirna.mirbase_isomiRs.tsv"

#### Modules ####
include: "rules/preprocessing.smk"
include: "rules/mapping.smk"
