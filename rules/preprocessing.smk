rule first_adapter_removal_next:
    input:   "raw_fastq/{sample}.fastq.gz",
    output:  trimmed = "results/trimmed_seqs/{sample}.first_trim.fastq.gz",
             short = "results/trimmed_seqs/{sample}.first_short.fastq.gz",
             text = "results/trimmed_seqs/cutadapt/{sample}.first_trim_cutadapt.txt",
             qual_filter = "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
    log:     "logs/first_trim/{sample}/first_trim.log"
    threads: 10
    params:  quality_base = ["quality_base"],
             adapter = ["adapter_seq"],
             error_rate = ["error_rate"],
             min_overlap = ["min_overlap"],
             remove_adap = ["adapters_to_remove"],
             disc_short = ["disc_short"],
             max_n = ["max_n"],
             kit = config["kit"],
    conda:   "../wrappers/first_trim/env.yaml"
    script:  "../wrappers/first_trim/script.py"

if config["kit"] == "truseq" or config["kit"] == "nextflex_v4":
    rule collapse_sequences_truseq:
        input:   trimmed = "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  cleaned = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/collapse_samples/{sample}/collapse_sequences.log"
        threads: 10
        conda:   "../wrappers/truseq_collapse/env.yaml"
        script:  "../wrappers/truseq_collapse/script.py"

if config["kit"] == "nextflex_v3":
    rule nextflex_adapter_removal_collapsed:
        input:   "results/trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  trimmed = "results/trimmed_seqs/{sample}.second_trim.fastq.gz",
                 text = "results/trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt",
                 cleaned = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_trim.log"
        threads: 10
        params:  left_trim = ["left_trim"],
                 right_trim = ["right_trim"]
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
        threads: 10
        params:  adapter_seq = ["second_adapter"],
                 quality_base = ["quality_base"],
                 error_rate = ["error_rate"],
                 min_overlap = ["min_overlap"],
                 remove_adap = ["adapters_to_remove"],
                 disc_short = ["disc_short"],
                 min_length = ["min_length"],
                 max_n = ["max_n"]
        conda:  "../wrappers/qiaseq_adapter_removal/env.yaml"
        script: "../wrappers/qiaseq_adapter_removal/script.py"

rule all_quality_control:
    input:   clean = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz",
    output:  trim = "results/qc_reports/{sample}.first_trim.lowQclean_fastqc.html",
             clean = "results/qc_reports/{sample}.clean_collapsed_fastqc.html",
             second = "results/qc_reports/{sample}.second_trim_fastqc.html" if config["kit"] == "nextflex_v3" else "results/qc_reports/{sample}.first_short_fastqc.html",
    log:     "logs/final_qc/{sample}/adapt1_trim_qc.log"
    threads: 10
    params:  formats = ["format"]
    conda:   "../wrappers/quality_control/env.yaml"
    script:  "../wrappers/quality_control/script.py"

def multiqc_input(wildcards):
    inputs = {
        'first_trim': expand("results/qc_reports/{sample}.first_trim.lowQclean_fastqc.html", sample = sample_tab.sample_name),
        'first_cutadapt': expand("results/trimmed_seqs/cutadapt/{sample}.first_trim_cutadapt.txt", sample = sample_tab.sample_name),
        'clean': expand("results/qc_reports/{sample}.clean_collapsed_fastqc.html", sample = sample_tab.sample_name)
        }
    if config["kit"] == "nextflex_v3" or config["kit"] == "qiaseq":
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
    threads: 10
    params:  clean = "--ignore \"*short*\" --ignore \"*untrim*\"",
             others = "--ignore \"*collapsed*\" --ignore \"*first_trim*\" --ignore \"*second_trim*\"",
    conda:   "../wrappers/merge_qc/env.yaml"
    script:  "../wrappers/merge_qc/script.py"

rule sequence_counts:
    input:   trimmed = "results/qc_reports/{sample}.clean_collapsed_fastqc.html"
    output:  summary = "results/sequences_summary/{sample}.sequences_summary.txt"
    log:     "logs/sequence_counts/{sample}/sequences_summary.log"
    threads: 10
    conda:   "../wrappers/sequence_counts/env.yaml"
    script:  "../wrappers/sequence_counts/script.py"