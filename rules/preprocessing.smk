
rule preprocess:
    input:  raw = expand("raw_fastq/{{sample}}{read_tags}.fastq.gz",read_tags=pair_tag),
    output: cleaned = expand("cleaned_fastq/{{sample}}{read_tags}.fastq.gz",read_tags=pair_tag),
    log:    "logs/{sample}/preprocessing.log"
    threads: 10
    resources:  mem = 10
    params: adaptors = config["trim_adapters"],
            library_type= config["library_type"]
    conda:  "../wrappers/preprocess/env.yaml"
    script: "../wrappers/preprocess/script.py"
