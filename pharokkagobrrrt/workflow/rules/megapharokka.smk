rule run_megapharokka:
    input:
        lambda wildcards: fasta_files[wildcards.sample]
    output:
        os.path.join(config["args"]["temp"], "{sample}.pharokka", "pharokka.gbk")
    params:
        dir = os.path.join(config["args"]["temp"], "{sample}.pharokka"),
        db = config["args"]["db"],
        params = config["megapharokka"]
    threads:
        config["resources"]["big"]["cpu"]
    resources:
        mem = config["resources"]["big"]["mem"] + "MB",
        time = config["resources"]["big"]["time"]
    conda:
        os.path.join(config["args"]["envs"], "pharokka.yaml")
    group:
        "megapharokka"
    benchmark:
        os.path.join(config["args"]["bench"], "run_megapharokka.{sample}.log")
    log:
        os.path.join(config["args"]["log"], "run_megapharokka.{sample}.log")
    shell:
        """
        megapharokka.py \
            -i {input} \
            -o {params.dir} \
            -d {params.db} \
            -t {threads} \
            {params.params}
        """


rule pack_megapharokka:
    input:
        gbk = os.path.join(config["args"]["temp"],"{sample}.pharokka","pharokka.gbk")
    output:
        gbk = os.path.join(config["args"]["results"], "{sample}.gbk"),
        tar = os.path.join(config["args"]["archive"], "{sample}.tar.zst")
    params:
        dir = os.path.join(config["args"]["temp"],"{sample}.pharokka")
    group:
        "megapharokka"
    benchmark:
        os.path.join(config["args"]["bench"], "pack_megapharokka.{sample}.log")
    log:
        os.path.join(config["args"]["log"], "pack_megapharokka.{sample}.log")
    shell:
        """
        mv {input.gbk} {output.gbk}
        tar --zstd --remove-files -cvf {output.tar} {params.dir}
        """
