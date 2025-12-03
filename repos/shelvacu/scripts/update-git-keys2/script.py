import json
import requests
from scriptipy import *
import argparse
from pydantic import BaseModel
from pathlib import Path
import os


class NixData(BaseModel):
    sops_bin: Path
    nix_stuff: Path


data = NixData(**json.loads(os.environ["NIX_DATA"]))

parser = argparse.ArgumentParser()
parser.add_argument("domain")
args = parser.parse_args()

res = run(
    data.sops_bin,
    "--extract",
    f'["{args.domain}"]',
    "-d",
    data.nix_stuff / "secrets/misc/git-keys.json",
).json()
