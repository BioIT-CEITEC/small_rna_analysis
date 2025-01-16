rule rrna_mapping:
    input:  clean = "trimmed_seqs/{sample}.clean_collapsed.fastq.gz",
            rrna = config["organism_rrna_star"] #defined in bioroots utils
    output: bam = "mapped/{sample}.rnar.Aligned.out.bam",
            log_final = "mapped/{sample}.rnar.Log.final.out",
            log = "mapped/{sample}.rnar.Log.out",
            log_progress = "mapped/{sample}.rnar.Log.progress.out",
            sj = "mapped/{sample}.rnar.SJ.out.tab",
            unmapped = "mapped/{sample}.rnar.Unmapped.out.fastq.gz",
            mapping_stats = "mapped/rrna_stats/{sample}_rrna_mapping.txt"
    log:    "logs/mapping/{sample}/rrna_mapping.log"
    threads: 30
    params: tmpd = GLOBAL_TMPD_PATH
    conda:  "../wrappers/rrna_mapping/env.yaml"
    script: "../wrappers/rrna_mapping/script.py"

rule mirna_alignment:
    input:  unmapped = "mapped/{sample}.rnar.Unmapped.out.fastq.gz",
            miraligner_db = config["organism_mirbase"] #defined in bioroots utils
    output: mirna = "mapped/miraligner/{sample}.mirna",
            unmapped = "mapped/miraligner/{sample}.mirna.unmapped.fastq.gz"
    log:    "logs/mapping/{sample}/miraligner.log"
    threads: 10
    params: mir_mismatch = config["mir_mismatch"],
            mir_trim = config["mir_trim"],
            mir_add = config["mir_add"],
            mir_minl = config["mir_minl"],
            species = config["organism_code"], #defined in bioroots utils
            miraligner = config["tool_path"] #defined in bioroots utils
    conda:  "../wrappers/miraligner/env.yaml"
    script: "../wrappers/miraligner/script.py"

rule mirna_counts:
    input:  mirna = expand("mapped/miraligner/{sample}.mirna", sample = sample_tab.sample_name)
    output: canon_counts = expand("qc_reports/{sample}/mirbase_canonical/{sample}.mirbase_canonical.tsv", sample = sample_tab.sample_name),
            isomir_counts = expand("qc_reports/{sample}/mirbase_isomiRs/{sample}.mirbase_isomiRs.tsv", sample = sample_tab.sample_name)
    log:    "logs/counts/canonical_isomiRs_counts.log"
    threads: 10
    conda:  "../wrappers/miRNA_counts/env.yaml"
    script: "../wrappers/miRNA_counts/script.py"