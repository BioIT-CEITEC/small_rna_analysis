def merge_fastq_qc_input(wcs):
    inputs = {'html': expand("qc_reports/{sample}/raw_fastqc/{read_pair_tag}_fastqc.html",sample = sample_tab.sample_name, read_pair_tag = read_pair_tags)}
    if config['check_adaptors']:
        inputs['minion'] = "qc_reports/raw_fastq_minion_adaptors_mqc.tsv"
    if config['biobloom']:
        inputs['biobloom'] = expand("qc_reports/{sample}/biobloom/{sample}.biobloom_summary.tsv",sample = sample_tab.sample_name)
    if config['species_detector']:
        inputs['sp_det'] = "qc_reports/species_detector_summary_mqc.tsv"
    return inputs

rule merge_fastq_qc:
    input:  unpack(merge_fastq_qc_input)
    output: html = "qc_reports/raw_fastq_multiqc.html"
    log:    "logs/merge_fastq_qc.log"
    conda:  "../wrappers/merge_fastq_qc/env.yaml"
    script: "../wrappers/merge_fastq_qc/script.py"


def raw_fastq_qc_input(wildcards):
    if wildcards.read_pair_tag == "SE":
        input_fastq_read_pair_tag = ""
    else:
        input_fastq_read_pair_tag = "_" + wildcards.read_pair_tag
    #print(f'{dirname}/raw_fastq/{wildcards.sample}{input_fastq_read_pair_tag}.fastq.gz')
    return f'{dirname}/raw_fastq/{wildcards.sample}{input_fastq_read_pair_tag}.fastq.gz'

rule raw_fastq_qc:
    input:  raw_fastq = raw_fastq_qc_input
    output: html = "qc_reports/{sample}/raw_fastqc/{read_pair_tag}_fastqc.html"
    log:    "logs/{sample}/raw_fastqc_{read_pair_tag}.log"
    params: extra = "--noextract --format fastq --nogroup",
    threads:  1
    conda:  "../wrappers/raw_fastq_qc/env.yaml"
    script: "../wrappers/raw_fastq_qc/script.py"
