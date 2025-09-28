#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.pydantic -p nix-fast-build
import glob
import json
import logging
import multiprocessing
import os
import re
import subprocess
import sys
import tempfile
from typing import Callable, Dict, List, Optional, Tuple

from pydantic import BaseModel


class BuildResult(BaseModel):
    attr: str
    duration: float
    error: Optional[str]
    success: bool
    type: str


class FastBuildResults(BaseModel):
    results: List[BuildResult]


class PackageInfo(BaseModel):
    description: str
    pname: str
    version: str


def run_process_with_live_output(
    cmd: List[str],
    logger: logging.Logger,
    output_filter: Optional[Callable[[str], bool]] = None,
) -> Tuple[int, str]:
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        universal_newlines=True,
    )

    captured_output = ""
    if process.stdout:
        for line in process.stdout:
            line = line.rstrip()
            if line:
                if not output_filter or output_filter(line):
                    logger.info(f"  {line}")
                captured_output += line + "\n"

    process.wait()
    return process.returncode, captured_output


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    logger = logging.getLogger(__name__)

    package_set = sys.argv[1]
    architecture = sys.argv[2]

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".json", delete=False
    ) as temp_result_file:
        result_file_path = temp_result_file.name

    try:
        build_cmd = [
            "nix-fast-build",
            "-f",
            f".#{package_set}.{architecture}",
            "--skip-cached",
            "--no-nom",
            "--no-link",
            f"-j{multiprocessing.cpu_count()}",
            "--result-file",
            result_file_path,
            "--result-format",
            "json",
        ]

        run_process_with_live_output(
            build_cmd, logger, lambda line: "nix_fast_build" in line
        )

        with open(result_file_path) as f:
            results = FastBuildResults.model_validate_json(f.read())
    finally:
        if os.path.exists(result_file_path):
            os.remove(result_file_path)

    with open("nix-packages.json") as f:
        raw_packages = json.loads(f.read())
        nix_packages = {
            k: PackageInfo.model_validate(v) for k, v in raw_packages.items()
        }

    error_flag = False

    for result in results.results:
        if not result.success:
            attr_name = result.attr

            full_attr_path = None
            for path in nix_packages.keys():
                if f".{architecture}." in path and path.endswith(f".{attr_name}"):
                    full_attr_path = path
                    break

            if not full_attr_path:
                error_flag = True
                continue

            logger.info(f"Processing failed package: {attr_name} ({full_attr_path})")
            if not build_and_fix_hashes(full_attr_path, logger):
                error_flag = True

    sys.exit(1 if error_flag else 0)


def build_and_fix_hashes(attr_path: str, logger: logging.Logger) -> bool:
    attempt = 1
    while True:
        logger.info(f"Attempt {attempt}: Building {attr_path}")

        returncode, stderr_content = run_process_with_live_output(
            ["nix", "build", "--no-link", f".#{attr_path}"], logger
        )

        if returncode == 0:
            logger.info(f"Build successful for {attr_path}")
            return True

        hash_pairs = parse_hash_mismatches(stderr_content)

        if not hash_pairs:
            logger.error(f"Build failed for {attr_path} (no hash mismatches found)")
            return False

        logger.info(f"Found {len(hash_pairs)} hash mismatches")
        replacement_made = False
        for specified_hash, got_hash in hash_pairs:
            if replace_hash_in_files(specified_hash, got_hash, logger):
                replacement_made = True

        if not replacement_made:
            logger.error(f"No hash replacements made for {attr_path}")
            return False

        logger.info(f"Hash replacements completed, retrying build")
        attempt += 1


def parse_hash_mismatches(stderr: str) -> List[Tuple[str, str]]:
    hash_pairs = []
    lines = stderr.split("\n")

    for i, line in enumerate(lines):
        if "specified:" in line and i + 1 < len(lines):
            specified_match = re.search(r"sha256-[A-Za-z0-9+/=]+", line)
            got_match = re.search(r"sha256-[A-Za-z0-9+/=]+", lines[i + 1])

            if specified_match and got_match:
                hash_pairs.append((specified_match.group(), got_match.group()))

    return hash_pairs


def replace_hash_in_files(old_hash: str, new_hash: str, logger: logging.Logger) -> bool:
    replacement_made = False

    for file_path in glob.glob("pkgs/**/*.nix", recursive=True):
        try:
            with open(file_path) as f:
                content = f.read()

            if old_hash in content:
                new_content = content.replace(old_hash, new_hash)
                with open(file_path, "w") as f:
                    f.write(new_content)
                logger.info(f"Replaced hash in {file_path}: {old_hash} -> {new_hash}")
                replacement_made = True
        except:
            continue

    return replacement_made


if __name__ == "__main__":
    main()
