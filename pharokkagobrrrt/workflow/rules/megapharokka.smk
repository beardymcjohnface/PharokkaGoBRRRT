rule unzip_reference:
    input:
        lambda wildcards: fasta_files[wildcards.sample]
    output:
        temp(os.path.join(config["args"]["temp"], "{sample}.fasta"))
    shell:
        "zcat {input} > {output}"


rule run_megapharokka:
    input:
        os.path.join(config["args"]["temp"], "{sample}.fasta")
    output:
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
        "megapharokka.py "
            "-i {input} "
            "-o {params.dir} "
            "-d {params.db} "
            "-t {threads} "
            "{params.params} "
            "&> {log} \n"
        "mv {params.gbk} {output.gbk} \n"
        "tar --remove-files -cf - {params.dir} "
            "| zstd -T{threads} -o {output.tar} \n"


# rule results_to_s3:
#     """Assumes aws cli is loaded"""
#     input:
#         gbk = os.path.join(config["args"]["results"],"{sample}.gbk"),
#         tar = os.path.join(config["args"]["archive"],"{sample}.tar.zst")
#     output:
#         gbk = S3.remote(config["s3"]["path"] + "{sample}.gbk"),
#         tar = S3.remote(config["s3"]["path"] + "{sample}.tar.zst")
#     params:
#         config["s3"]["params"]
#     shell:
#         """
#         aws s3 cp {input.gbk} s3://{output.gbk} {params}
#         aws s3 cp {input.tar} s3://{output.tar} {params}
#         """
