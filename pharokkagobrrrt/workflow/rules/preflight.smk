import glob
import re


# Concatenate Snakemake's own log file with the master log file
def copy_log_file():
    files = glob.glob(os.path.join(".snakemake", "log", "*.snakemake.log"))
    if not files:
        return None
    current_log = max(files, key=os.path.getmtime)
    shell("cat " + current_log + " >> " + config['args']['log'])

onsuccess:
    copy_log_file()

onerror:
    copy_log_file()


# directories
config["args"]["envs"] = os.path.join("..", "envs")
config["args"]["temp"] = os.path.join(config["args"]["output"], "temp")
config["args"]["results"] = os.path.join(config["args"]["output"], "results")
config["args"]["archive"] = os.path.join(config["args"]["output"], "archive")
config["args"]["bench"] = os.path.join(config["args"]["output"], "bench")
config["args"]["logdir"] = os.path.join(config["args"]["output"], "log")


# parse input contigs
fasta_files = {}
file_list = glob.glob(os.path.join(config['args']['input'], "*"))
for file_path in file_list:
    file_name = os.path.basename(file_path)
    if file_name.lower().endswith(
        (".fasta.gz", ".fa.gz", ".fna.gz", ".ffn.gz", ".faa.gz", ".frn.gz")
    ):
        file_name = re.sub(r"\.f[frnast]+\.gz$","",file_name)
        fasta_files[file_name] = file_path
fasta_list = list(fasta_files.keys())


# Targets
targets = []
targets.append(expand(os.path.join(config["args"]["results"],"{sample}.gbk"), sample=fasta_list))
targets.append(expand(os.path.join(config["args"]["results"],"{sample}.pharokka.gbk"), sample=fasta_list))
targets.append(expand(os.path.join(config["args"]["archive"],"{sample}.tar.zst"), sample=fasta_list))
targets.append(expand(os.path.join(config["args"]["archive"],"{sample}.pharokka.tar.zst"), sample=fasta_list))
targets.append(expand(os.path.join(config["args"]["temp"], "{sample}.done"), sample=fasta_list))
