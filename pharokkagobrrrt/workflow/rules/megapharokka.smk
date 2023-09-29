rule run_megapharokka:
    input:
        lambda wildcards: fasta_files[wildcards.sample]
    output:
        faa = temp(os.path.join(config["args"]["temp"], "{sample}.fasta")),
        gbk = os.path.join(config["args"]["results"],"{sample}.gbk"),
        tar = os.path.join(config["args"]["archive"],"{sample}.tar.zst")
    params:
        dir = os.path.join(config["args"]["temp"], "{sample}.pharokka"),
        gbk = os.path.join(config["args"]["temp"],"{sample}.pharokka","pharokka.gbk"),
        db = config["args"]["db"],
        params = config["megapharokka"]
    threads:
        config["resources"]["big"]["cpu"]
    resources:
        mem = str(config["resources"]["big"]["mem"]) + "MB",
        time = config["resources"]["big"]["time"]
    conda:
        os.path.join(config["args"]["envs"], "pharokka.yaml")
    benchmark:
        os.path.join(config["args"]["bench"], "run_megapharokka.{sample}.log")
    log:
        os.path.join(config["args"]["logdir"], "run_megapharokka.{sample}.log")
    shell:
        "zcat {input} > {output.faa} \n\n"
        "megapharokka.py "
            "-i {output.faa} "
            "-o {params.dir} "
            "-d {params.db} "
            "-t {threads} "
            "{params.params} "
            "&> {log} \n\n"
        "mv {params.gbk} {output.gbk} \n\n"
        "tar --remove-files -cf - {params.dir} "
            "| zstd -T{threads} -o {output.tar} \n\n"


rule results_to_s3:
    """Assumes aws cli is loaded"""
    input:
        gbk = os.path.join(config["args"]["results"],"{sample}.gbk"),
        tar = os.path.join(config["args"]["archive"],"{sample}.tar.zst")
    output:
        gbk = S3.remote(os.path.join(config["s3"]["path"], "{sample}.gbk")),
        tar = S3.remote(os.path.join(config["s3"]["path"], "{sample}.tar.zst"))
    params:
        config["s3"]["params"]
    shell:
        "aws s3 cp {input.gbk} s3://{output.gbk} {params}\n\n"
        "aws s3 cp {input.tar} s3://{output.tar} {params}\n\n"
