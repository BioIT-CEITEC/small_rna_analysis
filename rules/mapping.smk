rule rrna_mapping:
    input: clean = "results/trimmed_seqs/{sample}.clean_collapsed.fastq.gz"
    output: bam = "results/mapped_seqs/{sample}.rnar.Aligned.out.bam",
            log_final = "results/mapped_seqs/{sample}.rnar.Log.final.out",
            log = "results/mapped_seqs/{sample}.rnar.Log.out",
            log_progress = "results/mapped_seqs/{sample}.rnar.Log.progress.out",
            sj = "results/mapped_seqs/{sample}.rnar.SJ.out.tab",
            unmapped = "results/mapped_seqs/{sample}.rnar.Unmapped.out.fastq.gz",
            mapping_stats = "results/mapped_seqs/rrna_stats/{sample}_rrna_mapping.txt"
    log: "logs/mapping/{sample}/rrna_mapping.log"
    threads: config["preprocessing"][config["kit"]]["threads"]
    params: nthreads = config["nthreads"],
            genome_ref = config["genome_ref"],
            max_multimap = config["max_multimap"],
            min_multimap = config["min_multimap"],
            filter_mismatch = config["filter_mismatch"],
            score_range = config["score_range"],
            min_over = config["min_over"],
            filtermax_mismatch = config["filtermax_mismatch"],
            intron_max = config["intron_max"],
            intron_min = config["intron_min"],
            seed_search = config["seed_search"],
            anchor_multimap = config["anchor_multimap"]
    conda: "../wrappers/rrna_mapping/env.yaml"
    script: "../wrappers/rrna_mapping/script.py"

rule mirna_alignment:
        input:   unmapped = "results/mapped_seqs/{sample}.rnar.Unmapped.out.fastq.gz"
        output:  mirna = "results/mapped_seqs/miraligner/{sample}.mirna",
                 unmapped = "results/mapped_seqs/miraligner/{sample}.mirna.unmapped.fastq.gz",
        log:     "logs/mapping/{sample}/miraligner.log"
        threads: config["preprocessing"][config["kit"]]["threads"]
        params:  miraligner = config["miraligner"],
                 mir_mismatch = config["mir_mismatch"],
                 mir_trim = config["mir_trim"],
                 mir_add = config["mir_add"],
                 mir_minl = config["mir_minl"],
                 species = config["species"],
                 database = config["database"]            
        conda:   "../wrappers/miraligner/env.yaml"
        script:  "../wrappers/miraligner/script.py"

rule mirna_counts:
        input:  mirna = expand("results/mapped_seqs/miraligner/{sample}.mirna", sample = sample_tab.sample_name)
        output: "results/mapped_seqs/miraligner/mirna.mirbase_canonical.tsv",
                #canon_counts = expand("results/qc_reports/{sample}/mirbase_canonical/{sample}.mirbase_canonical.tsv", sample = sample_tab.sample_name),
                #isomir_counts = expand("results/qc_reports/{sample}/mirbase_isomiRs/{sample}.mirbase_isomiRs.tsv", sample = sample_tab.sample_name)
        log:    "logs/counts/canonical_isomiRs_counts.log"
        params: script_counts = config["script_counts"]
        conda:  "../wrappers/miRNA_counts/env.yaml"
        script: "../wrappers/miRNA_counts/script.py"