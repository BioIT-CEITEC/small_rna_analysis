rule first_adapter_removal_next:
    input:   "raw_fastq/{sample}.fastq.gz",
    output: trimmed = "trimmed_seqs/{sample}.first_trim.fastq.gz",
            short = "trimmed_seqs/{sample}.first_short.fastq.gz",
            text = "trimmed_seqs/cutadapt/{sample}.first_trim_cutadapt.txt",
            qual_filter = "trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
    log:     "logs/first_trim/{sample}/first_trim.log"
    threads: 10
    params: adapter = config["adapter_seq"],
            error_rate = config["error_rate"],
            min_overlap = config["min_overlap"],
            disc_short = config["disc_short"],
            kit = config["kit"]
    conda:   "../wrappers/first_trim/env.yaml"
    script:  "../wrappers/first_trim/script.py"

if config["kit"] == "truseq" or config["kit"] == "nextflex_v4":
    rule collapse_sequences_truseq:
        input:   trimmed = "trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  cleaned = "trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/collapse_samples/{sample}/collapse_sequences.log"
        threads: 10
        conda:   "../wrappers/truseq_collapse/env.yaml"
        script:  "../wrappers/truseq_collapse/script.py"

if config["kit"] == "nextflex_v3":
    rule nextflex_adapter_removal_collapsed:
        input:   "trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output: trimmed = "trimmed_seqs/{sample}.second_trim.fastq.gz",
                text = "trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt",
                cleaned = "trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_trim.log"
        threads: 10
        conda:   "../wrappers/nextflex_adapter_removal/env.yaml"
        script:  "../wrappers/nextflex_adapter_removal/script.py"

if config["kit"] == "qiaseq":
    rule qiaseq_adapter_removal_collapsed:
        input:   input_second_adapter = "trimmed_seqs/{sample}.first_trim.lowQclean.fastq.gz"
        output:  first_collapse = "trimmed_seqs/{sample}.collapsed.fastq.gz",
                short = "trimmed_seqs/{sample}.second_short.fastq.gz",
                untrimmed = "trimmed_seqs/{sample}.second_untrim.fastq.gz",
                text = "trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt",
                second_collapse = "trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_adapter_removal.log"
        threads: 10
        params: adapter_seq = config["adapter_2"],
                error_rate = config["error_rate"],
                min_overlap = config["min_overlap"],
                disc_short = config["disc_short"]
        conda:  "../wrappers/qiaseq_adapter_removal/env.yaml"
        script: "../wrappers/qiaseq_adapter_removal/script.py"

rule all_quality_control:
    input:  clean = "trimmed_seqs/{sample}.clean_collapsed.fastq.gz",
    output: trim = "qc_reports/{sample}.first_trim.lowQclean_fastqc.html",
            clean = "qc_reports/{sample}.clean_collapsed_fastqc.html",
            second = "qc_reports/{sample}.second_trim_fastqc.html" if config["kit"] == "nextflex_v3" else "qc_reports/{sample}.first_short_fastqc.html",
    log:     "logs/final_qc/{sample}/adapt1_trim_qc.log"
    threads: 10
    conda:   "../wrappers/quality_control/env.yaml"
    script:  "../wrappers/quality_control/script.py"

def multiqc_input(wildcards):
    inputs = {
        'first_trim': expand("qc_reports/{sample}.first_trim.lowQclean_fastqc.html", sample = sample_tab.sample_name),
        'first_cutadapt': expand("trimmed_seqs/cutadapt/{sample}.first_trim_cutadapt.txt", sample = sample_tab.sample_name),
        'clean': expand("qc_reports/{sample}.clean_collapsed_fastqc.html", sample = sample_tab.sample_name)
        }
    if config["kit"] == "nextflex_v3" or config["kit"] == "qiaseq":
        inputs['second_trim'] = expand("qc_reports/{sample}.second_trim_fastqc.html", sample = sample_tab.sample_name)
        inputs['second_cutadapt'] = expand("trimmed_seqs/cutadapt/{sample}.second_trim_cutadapt.txt", sample = sample_tab.sample_name)
    else:
        inputs
    return inputs

rule merge_all_qc_next:
    input:   unpack(multiqc_input)
    output:  trimmed = "qc_reports/multiqc/trimmed/trimmed_multiqc.html",
             cutadapt = "qc_reports/multiqc/cutadapt/cutadapt_multiqc.html",
             untrim_short = "qc_reports/multiqc/untrim_short/untrim_short_multiqc.html",
             cleaned_collapsed = "qc_reports/multiqc/clean_collapsed/clean_collapsed_multiqc.html"
    log:     "logs/merge_qc/first_merge_qc_reports.log"
    threads: 10
    params:  trimmed = "--ignore \"*short*\" --ignore \"*untrim*\" --ignore \"*collapsed*\",
             others = "--ignore \"*collapsed*\" --ignore \"*first_trim*\" --ignore \"*second_trim*\"",
    conda:   "../wrappers/merge_qc/env.yaml"
    script:  "../wrappers/merge_qc/script.py"

rule sequence_counts:
    input:   trimmed = "qc_reports/{sample}.clean_collapsed_fastqc.html"
    output:  summary = "sequences_summary/{sample}.sequences_summary.txt"
    log:     "logs/sequence_counts/{sample}/sequences_summary.log"
    threads: 10
    conda:   "../wrappers/sequence_counts/env.yaml"
    script:  "../wrappers/sequence_counts/script.py"