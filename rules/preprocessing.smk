rule first_adapter_removal_next:
        input:   "raw_samples/{sample}.fastq.gz",
        output:  trimmed = "results/trimmed_seqs/{sample}_first_trim.fastq.gz",
                 short = "results/trimmed_seqs/{sample}_first_short.fastq.gz",
                 untrimmed = "results/trimmed_seqs/{sample}_short_untrim.fastq.gz",
                 text = "results/trimmed_seqs/cutadapt/{sample}_first_trim_cutadapt.txt"
        log:     "logs/first_trim/{sample}/first_trim.log"
        threads: config["threads"]
        params:  quality_base = config["quality_base"],
                 adapter = config["adapter_seq"],
                 error_rate = config["error_rate"],
                 min_overlap = config["min_overlap"],
                 remove_adap = config["adapters_to_remove"],
                 disc_short = config["disc_short"],
                 max_n = config["max_n"]
        conda:   "../wrappers/first_trim/env.yaml"
        script:  "../wrappers/first_trim/script.py"

if config["kit"] == "truseq":
    rule collapse_sequences_truseq:
        input:   trimmed = "results/trimmed_seqs/{sample}_first_trim.fastq.gz"
        output:  cleaned = "results/trimmed_seqs/{sample}_clean_collapsed.fastq.gz"
        log:     "logs/collapse_samples/{sample}/collapse_sequences.log"
        threads: ["threads"]
        params:  extra = "qfake=40 in=stdin.fa out=stdout.fq",
                 script = "resources/change_header_format.py"
        conda:   "../wrappers/truseq_collapse/env.yaml"
        script:  "../wrappers/truseq_collapse/script.py"

if config["kit"] == "nextflex":
    rule nextflex_adapter_removal_collapsed:
        input:   "results/trimmed_seqs/{sample}_first_trim.fastq.gz"
        output:  trimmed = "results/trimmed_seqs/{sample}_second_trim.fastq.gz",
                 text = "results/trimmed_seqs/cutadapt/{sample}_second_trim_cutadapt.txt",
                 cleaned = "results/trimmed_seqs/{sample}_clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_trim.log"
        threads: config["threads"]
        params:  left_trim = config["left_trim"],
                 right_trim = config["right_trim"],
                 extra = "qfake=40 in=stdin.fa out=stdout.fq",
                 script = "resources/change_header_format.py",
        conda:   "../wrappers/nextflex_adapter_removal/env.yaml"
        script:  "../wrappers/nextflex_adapter_removal/script.py"

if config["kit"] == "qiaseq":
    rule qiaseq_adapter_removal_collapsed:
        input:   input_second_adapter = "results/trimmed_seqs/{sample}_first_trim.fastq.gz"
        output:  first_collapse = "results/trimmed_seqs/{sample}_collapsed.fastq.gz",
                 trimmed = "results/trimmed_seqs/{sample}_second_trim.fastq.gz",
                 short = "results/trimmed_seqs/{sample}_second_short.fastq.gz",
                 untrimmed = "results/trimmed_seqs/{sample}_second_untrim.fastq.gz",
                 text = "results/trimmed_seqs/cutadapt/{sample}_second_trim_cutadapt.txt",
                 second_collapse = "results/trimmed_seqs/{sample}_clean_collapsed.fastq.gz"
        log:     "logs/second_trim/{sample}/second_adapter_removal.log"
        threads: config["threads"]
        params:  adapter_seq = config["adapter_2"],
                 quality_base = config["quality_base"],
                 error_rate = config["error_rate"],
                 min_overlap = config["min_overlap"],
                 remove_adap = config["adapters_to_remove"],
                 disc_short = config["disc_short"],
                 min_length = config["min_length"],
                 max_n = config["max_n"],
                 extra = "qfake=40 in=stdin.fa out=stdout.fq",
                 script = "resources/change_header_format.py",
        conda:   "../wrappers/qiaseq_adapter_removal/env.yaml"
        script:  "../wrappers/qiaseq_adapter_removal/script.py"

def all_qc_outputs(wildcards):
    inputs = {
        'first_trim': "results/qc_reports/{sample}_first_trim_fastqc.html",
        'clean': "results/qc_reports/{sample}_clean_collapsed_fastqc.html",
    }
    if config["kit"] != "truseq":
        inputs['second'] = "results/qc_reports/{sample}_second_trim_fastqc.html"
    else:
        inputs
    return inputs

rule all_quality_control:
        input:   trim = "results/trimmed_seqs/{sample}_first_trim.fastq.gz",
                 clean = "results/trimmed_seqs/{sample}_clean_collapsed.fastq.gz",
        output:  trim = "results/qc_reports/{sample}_first_trim_fastqc.html",
                 clean = "results/qc_reports/{sample}_clean_collapsed_fastqc.html",
                 second = "results/qc_reports/{sample}_second_trim_fastqc.html" if config["kit"] != "truseq" else "results/qc_reports/{sample}_short_untrim_fastqc.html",
        log:     "logs/final_qc/{sample}/adapt1_trim_qc.log"
        threads: config["threads"]
        params:  formats = config["format"]
        conda:   "../wrappers/quality_control/env.yaml"
        script:  "../wrappers/quality_control/script.py"

def multiqc_input(wildcards):
    inputs = {
        'first_trim': expand("results/qc_reports/{sample}_first_trim_fastqc.html", sample = sample_tab.sample_name),
        'first_cutadapt': expand("results/trimmed_seqs/cutadapt/{sample}_first_trim_cutadapt.txt", sample = sample_tab.sample_name),
        'clean': expand("results/qc_reports/{sample}_clean_collapsed_fastqc.html", sample = sample_tab.sample_name)
        }
    if config["kit"] != "truseq":
        inputs['second_trim'] = expand("results/qc_reports/{sample}_second_trim_fastqc.html", sample = sample_tab.sample_name)
        inputs['second_cutadapt'] = expand("results/trimmed_seqs/cutadapt/{sample}_second_trim_cutadapt.txt", sample = sample_tab.sample_name)
    else:
        inputs
    return inputs

rule merge_all_qc_next:
        input:   unpack(multiqc_input)
        output:  clean = "results/qc_reports/multiqc/clean_trim/clean_trim_multiqc.html",
                 cutadapt = "results/qc_reports/multiqc/cutadapt/cutadapt_multiqc.html",
                 untrim_short = "results/qc_reports/multiqc/untrim_short/untrim_short_multiqc.html"
        log:     "logs/merge_qc/first_merge_qc_reports"
        threads: config["threads"],
        params:  clean = "--ignore \"*short*\" --ignore \"*untrim*\"",
                 formats = config["format"],
                 others = "--ignore \"*collapsed*\" --ignore \"*first_trim*\" --ignore \"*second_trim*\"",
        conda:   "../wrappers/merge_qc/env.yaml"
        script:  "../wrappers/merge_qc/script.py"

rule sequence_counts:
        input:   trimmed = "results/qc_reports/{sample}_clean_collapsed_fastqc.html"
        output:  summary = "results/sequences_summary/sequences_summary.txt"
        log:     "logs/sequence_counts/sequences_summary.log"
        threads: config["threads"]
        params:  folder = "results/sequences_summary/zip_folder"
        conda:   "../wrappers/sequence_counts/env.yaml"
        script:  "../wrappers/sequence_counts/script.py"
