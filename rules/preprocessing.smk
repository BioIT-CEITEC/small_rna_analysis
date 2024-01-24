rule first_adapter_removal_next:
    input:   "raw_fastq/{sample}.fastq.gz",
    output:  trimmed = "results/trimmed_seqs/{sample}.first_trim.fastq.gz",
             short = "results/trimmed_seqs/{sample}.first_short.fastq.gz",
             text = "results/trimmed_seqs/cutadapt/{sample}.first_trim_cutadapt.txt",
             qual_filter = "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
    log:     "logs/first_trim/{sample}/first_trim.log"
    threads: config["preprocessing"][config["kit"]]["threads"]
    params:  quality_base = config["preprocessing"][config["kit"]]["quality_base"],
             adapter = config["preprocessing"][config["kit"]]["adapter_seq"],
             error_rate = config["preprocessing"][config["kit"]]["error_rate"],
             min_overlap = config["preprocessing"][config["kit"]]["min_overlap"],
             remove_adap = config["preprocessing"][config["kit"]]["adapters_to_remove"],
             disc_short = config["preprocessing"][config["kit"]]["disc_short"],
             max_n = config["preprocessing"][config["kit"]]["max_n"],
             kit = config["kit"],
             extra = " --untrimmed-output "
    conda:   "../wrappers/first_trim/env.yaml"
    script:  "../wrappers/first_trim/script.py"

if config["kit"] == "truseq" or config["kit"] == "nextflex_v4":
    rule collapse_sequences_truseq:
        input:   trimmed = "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  cleaned = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/collapse_samples/{sample}/collapse_sequences.log"
        threads: config["preprocessing"][config["kit"]]["threads"]
        params:  extra = config["extra"],
                 script = config["script"],
        conda:   "../wrappers/truseq_collapse/env.yaml"
        script:  "../wrappers/truseq_collapse/script.py"

if config["kit"] == "nextflex_v3":
    rule nextflex_adapter_removal_collapsed:
        input:   "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  trimmed = "results/trimmed_seqs/{sample}.second_trim.fastq.gz",
                 text = "results/trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt",
                 cleaned = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_trim.log"
        threads: config["preprocessing"][config["kit"]]["threads"]
        params:  left_trim = config["preprocessing"][config["kit"]]["left_trim"],
                 right_trim = config["preprocessing"][config["kit"]]["right_trim"],
                 extra = config["extra"],
                 script = config["script"],
                 bbmap = config["bbmap"]
        conda:   "../wrappers/nextflex_adapter_removal/env.yaml"
        script:  "../wrappers/nextflex_adapter_removal/script.py"

if config["kit"] == "qiaseq":
    rule qiaseq_adapter_removal_collapsed:
        input:   input_second_adapter = "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  first_collapse = "results/trimmed_seqs/{sample}.collapsed.fastq.gz",
                 short = "results/trimmed_seqs/{sample}.second_short.fastq.gz",
                 untrimmed = "results/trimmed_seqs/{sample}.second_untrim.fastq.gz",
                 text = "results/trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt",
                 second_collapse = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_adapter_removal.log"
        threads: config["preprocessing"][config["kit"]]["threads"]
        params:  adapter_seq = config["preprocessing"][config["kit"]]["adapter_2"],
                 quality_base = config["preprocessing"][config["kit"]]["quality_base"],
                 error_rate = config["preprocessing"][config["kit"]]["error_rate"],
                 min_overlap = config["preprocessing"][config["kit"]]["min_overlap"],
                 remove_adap = config["preprocessing"][config["kit"]]["adapters_to_remove"],
                 disc_short = config["preprocessing"][config["kit"]]["disc_short"],
                 min_length = config["preprocessing"][config["kit"]]["min_length"],
                 max_n = config["preprocessing"][config["kit"]]["max_n"],
                 extra = config["extra"],
                 script = config["script"],
                 bbmap = config["bbmap"]
        conda:  "../wrappers/qiaseq_adapter_removal/env.yaml"
        script: "../wrappers/qiaseq_adapter_removal/script.py"

rule all_quality_control:
    input:   clean = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz",
    output:  trim = "results/qc_reports/{sample}.first_trim.lowQclean_fastqc.html",
             clean = "results/qc_reports/{sample}.clean_collapsed_fastqc.html",
             second = "results/qc_reports/{sample}.second_trim_fastqc.html" if config["kit"] == "nextflex_v3" else "results/qc_reports/{sample}.first_short_fastqc.html",
    log:     "logs/final_qc/{sample}/adapt1_trim_qc.log"
    threads: config["preprocessing"][config["kit"]]["threads"]
    params:  formats = config["preprocessing"][config["kit"]]["format"]
    conda:   "../wrappers/quality_control/env.yaml"
    script:  "../wrappers/quality_control/script.py"

def multiqc_input(wildcards):
    inputs = {
        'first_trim': expand("results/qc_reports/{sample}.first_trim.lowQclean_fastqc.html", sample = sample_tab.sample_name),
        'first_cutadapt': expand("results/trimmed_seqs/cutadapt/{sample}.first_trim_cutadapt.txt", sample = sample_tab.sample_name),
        'clean': expand("results/qc_reports/{sample}.clean_collapsed_fastqc.html", sample = sample_tab.sample_name)
        }
    if config["kit"] == "nextflex_v3":
        inputs['second_trim'] = expand("results/qc_reports/{sample}.second_trim_fastqc.html", sample = sample_tab.sample_name)
        inputs['second_cutadapt'] = expand("results/trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt", sample = sample_tab.sample_name)
    else:
        inputs
    return inputs

rule merge_all_qc_next:
    input:   unpack(multiqc_input)
    output:  clean = "results/qc_reports/multiqc/clean_trim/clean_trim_multiqc.html",
             cutadapt = "results/qc_reports/multiqc/cutadapt/cutadapt_multiqc.html",
             untrim_short = "results/qc_reports/multiqc/untrim_short/untrim_short_multiqc.html"
    log:     "logs/merge_qc/first_merge_qc_reports.log"
    threads: config["preprocessing"][config["kit"]]["threads"],
    params:  clean = "--ignore \"*short*\" --ignore \"*untrim*\"",
             formats = config["preprocessing"][config["kit"]]["format"],
             others = "--ignore \"*collapsed*\" --ignore \"*first_trim*\" --ignore \"*second_trim*\"",
             folder = "results/qc_reports",
             cutadapt = "results/trimmed_seqs/cutadapt"
    conda:   "../wrappers/merge_qc/env.yaml"
    script:  "../wrappers/merge_qc/script.py"

rule sequence_counts:
    input:   trimmed = "results/qc_reports/{sample}.clean_collapsed_fastqc.html"
    output:  summary = "results/sequences_summary/{sample}.sequences_summary.txt"
    log:     "logs/sequence_counts/{sample}/sequences_summary.log"
    threads: config["preprocessing"][config["kit"]]["threads"]
    params:  folder = "results/sequences_summary/zip_folder"
    conda:   "../wrappers/sequence_counts/env.yaml"
    script:  "../wrappers/sequence_counts/script.py"