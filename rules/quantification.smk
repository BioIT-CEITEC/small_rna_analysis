
rule mirna_quantification:
    input:  mirna_outputs = expand("mapped/miRNA_align/{sample}.mirna",sample = sample_tab.sample_name),
    output: mirna_count = "quantification/miRNA/mirna_counts.tsv",
    log:    "logs/all_samples/mirna_quantification.log"
    threads: 40
    resources:  mem = 34
    params: prefix = "mapped/{sample}/{sample}",
            strandness = config["strandness"],
            num_mismatch= 999,  # Maximum number of mismatches; set this to high number (999) to disable and to use only perc_mismatch
            perc_mismatch= config["perc_mismatch"],
            max_intron= config["max_intron"],# Default used by ENCODE is 1000000; to turn this off set 1
            max_mate_dist=1000000,# Default used by ENCODE is 1000000; For "normal" fragments 1000 should be enough but for special cases, like chimeric we should increase this
            read_len=100,# Read length from the sequencing. Illumina sometimes reports N+1 http://seqanswers.com/forums/archive/index.php/t-31154.html; in case you change this value uncomment next line as well
            organism=config["organism"],
            map_perc= config["map_perc"],
            map_score=config["map_score"],
            paired = paired,
            tmpd = GLOBAL_TMPD_PATH,
    conda: "../wrappers/mirna_quantification/env.yaml"
    script: "../wrappers/mirna_quantification/script.py"


rule non_mirna_quantification:
    input:  bam = "mapped/genome_align/{sample}.bam",
            gtf = "resources/gtf/all_RNA_annotation.gtf"
    output: tsv = "quantification/non_miRNA/{sample}.tsv",
    log:    "logs/{sample}/non_mirna_quantification.log"
    threads: 40
    resources:  mem = 34
    params: prefix = "mapped/{sample}/{sample}",
            strandness = config["strandness"],
            num_mismatch= 999,  # Maximum number of mismatches; set this to high number (999) to disable and to use only perc_mismatch
            perc_mismatch= config["perc_mismatch"],
            max_intron= config["max_intron"],# Default used by ENCODE is 1000000; to turn this off set 1
            max_mate_dist=1000000,# Default used by ENCODE is 1000000; For "normal" fragments 1000 should be enough but for special cases, like chimeric we should increase this
            read_len=100,# Read length from the sequencing. Illumina sometimes reports N+1 http://seqanswers.com/forums/archive/index.php/t-31154.html; in case you change this value uncomment next line as well
            organism=config["organism"],
            map_perc= config["map_perc"],
            map_score=config["map_score"],
            paired = paired,
            tmpd = GLOBAL_TMPD_PATH,
    conda: "../wrappers/non_mirna_quantification/env.yaml"
    script: "../wrappers/non_mirna_quantification/script.py"