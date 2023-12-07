rule rrna_mapping:
        input:   clean = "results/trimmed_seqs/{sample}_clean_collapsed.fastq.gz",
        output:  bam = "results/mapped_seqs/{sample}.rnar.Aligned.out.bam",
                 log_final = "results/mapped_seqs/{sample}.rnar.Log.final.out",
                 log = "results/mapped_seqs/{sample}.rnar.Log.out",
                 log_progress = "results/mapped_seqs/{sample}.rnar.Log.progress.out",
                 sj = "results/mapped_seqs/{sample}.rnar.SJ.out.tab",
                 unmapped = "results/mapped_seqs/{sample}.rnar.Unmapped.out.mate1.fastq.gz",
                 mapping_stats = "results/mapped_seqs/rrna_stats/{sample}_rrna_mapping.txt"
        log:     "logs/mapping/{sample}/rrna_mapping.log"
        threads: config["threads"]
        params:  genome_ref = expand("{dir_ref}/tool_data/STAR", dir_ref = reference_directory)
                 nthreads = config["nthreads"],
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
        conda:   "../wrappers/rrna_mapping/env.yaml"
        script:  "../wrappers/rrna_mapping/script.py"

rule mirna_alignment:
        input:   unmapped = "results/mapped_seqs/{sample}.rnar.Unmapped.out.mate1.fastq.gz"
        output:  mirna = "results/mapped_seqs/miraligner/{sample}.mirna",
                 unmapped = "results/mapped_seqs/miraligner/{sample}.mirna.unmapped.fastq.gz",
        log:     "logs/mapping/{sample}/miraligner.log"
        threads: config["threads"]
        params:  database = expand("{ref_dir}/seq", ref_dir = reference_directory),
                 miraligner = "wrappers/miraligner/miraligner.jar",
                 mir_mismatch = config["mir_mismatch"],
                 mir_trim = config["mir_trim"],
                 mir_add = config["mir_add"],
                 mir_minl = config["mir_minl"],
                 species = config["species"],            
        conda:   "../wrappers/miraligner/env.yaml"
        script:  "../wrappers/miraligner/script.py"

rule mirna_counts:
        input:  mirna = "results/mapped_seqs/miraligner/{sample}.mirna"
        output: canon_counts = "results/mirbase_canonical/{sample}.mirbase_canonical.tsv",
                isomir_counts = "results/mirbase_isomiRs/{sample}.mirbase_isomiRs.tsv"
        log:    "logs/counts/{sample}/canonical_isomiRs_counts.log"
        params: script_counts = "wrappers/miRNA_counts/miraligner_mirna_counts.R"
        conda:  "../wrappers/miRNA_counts/env.yaml"
        script: "../wrappers/miRNA_counts/script.py"
