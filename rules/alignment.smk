
def alignment_RNA_input(wildcards):
    preprocessed = "cleaned_fastq"
    if read_pair_tags == ["SE"]:
        return os.path.join(preprocessed,"{sample}.fastq.gz")
    else:
        return [os.path.join(preprocessed,"{sample}_R1.fastq.gz"),os.path.join(preprocessed,"{sample}_R2.fastq.gz")]


rule alignment_to_rRNA:
    input:  fastqs = alignment_RNA_input,
            index = "resources/rRNA_STAR_index/SAindex",
    output: unmapped_fastq = "mapped/rRNA_align/{sample}.unmapped.fastq",
    log:    "logs/{sample}/rRNA_alignment.log"
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
    conda: "../wrappers/alignment_to_rRNA/env.yaml"
    script: "../wrappers/alignment_to_rRNA/script.py"



rule alignment_to_miRNA:
    input:  fastqs = "mapped/rRNA_align/{sample}.unmapped.fastq",
            index = "resources/mirBase_index/...TODO",
    output: unmapped_fastq = "mapped/miRNA_align/{sample}.unmapped.fastq",
            count_table = "mapped/miRNA_align/{sample}.mirna ... maybe different name TODO",
    log:    "logs/{sample}/miRNA_alignment.log"
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
    conda: "../wrappers/alignment_to_miRNA/env.yaml"
    script: "../wrappers/alignment_to_miRNA/script.py"

rule alignment_to_genome:
    input:  fastqs = "mapped/miRNA_align/{sample}.unmapped.fastq",
            index = "resources/mirBase_index/...TODO",
    output: bam = "mapped/genome_align/{sample}.bam",
    log:    "logs/{sample}/genome_alignment.log"
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
    conda: "../wrappers/alignment_to_genome/env.yaml"
    script: "../wrappers/alignment_to_genome/script.py"




