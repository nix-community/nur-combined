#!/usr/bin/env python3

import os
import webbrowser
import sys
import re
import time
import subprocess
from urllib.parse import urlparse


class Col:
    green = "\033[92m"
    cyan = "\033[96m"
    red = "\033[91m"
    blue = "\033[94m"
    grey = "\033[90m"
    purple = "\033[95m"
    endc = "\033[0m"


def get_nse_dir():
    """Resolve the directory containing gitlab_version.nse and gitlab_hashes.json."""
    # 1. Explicit override (Nix wrapper sets this)
    env = os.environ.get("GITLAB_VERSION_NSE_DIR")
    if env and os.path.isdir(env):
        return env

    # 2. Fallback: next to this script (for development / non-Nix usage)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    if os.path.exists(os.path.join(script_dir, "gitlab_version.nse")):
        return script_dir

    print("Error: cannot locate gitlab_version.nse data directory.")
    print("Set GITLAB_VERSION_NSE_DIR or place the NSE files next to this script.")
    sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("usage: gitlab_version <URL>")
        sys.exit(1)

    nse_dir = get_nse_dir()
    nse_script = os.path.join(nse_dir, "gitlab_version.nse")

    # Process the URL
    full_url = sys.argv[1]
    parsed_url = urlparse(full_url)
    scheme = parsed_url.scheme
    host = parsed_url.hostname
    port = parsed_url.port
    path = parsed_url.path

    if not port:
        port = 80 if scheme == "http" else 443

    # Check if the path contains anything besides "users/sign_in"
    additional_path = ""
    if path and path != "/users/sign_in":
        additional_path = "/" + path.strip("/")
        additional_path = additional_path.replace("users/sign_in", "")
        print(f"Additional path: {additional_path}")

    # Construct the nmap command
    nmap_command = [
        "nmap", host, "-Pn", "-p", str(port),
        "--script", nse_script,
        '--script-args=showcves',
    ]
    if additional_path:
        nmap_command.append(f'--script-args=subdir={additional_path}')

    # Execute the nmap command
    print(f"Executing: {' '.join(nmap_command)}")
    output = subprocess.run(nmap_command, capture_output=True, text=True)

    if "gitlab_version" not in output.stdout or "instance not found" in output.stdout:
        print("no output.. trying with -sV")
        nmap_command = [
            "nmap", host, "-Pn", "-p", str(port), "-sV",
            "--script", nse_script,
            '--script-args=showcves',
        ]
        if additional_path:
            nmap_command.append(f'--script-args=subdir={additional_path}')
        print(f"Executing: {' '.join(nmap_command)}")
        output = subprocess.run(nmap_command, capture_output=True, text=True)

    output = output.stdout
    lines_to_delete = [
        "Starting Nmap ", "Nmap scan report for ", "Host is up ",
        "PORT   STATE SERVICE", "Nmap done: ", "Service Info: ",
    ]

    cve_pattern = re.compile(r"CVE-\d\d\d\d-\d+\s+(\d+\.\d+)")
    cve_threshold = 7.0

    filtered_lines = []
    version_lines = []
    high_cves = []
    edition = "?"
    for line in output.split("\n"):
        if not any(phrase in line for phrase in lines_to_delete):
            filtered_lines.append(line)
            if "CVE" in line:
                cve_matches = cve_pattern.findall(line)
                for match in cve_matches:
                    cve_value = float(match)
                    if cve_value >= cve_threshold:
                        line = line.replace("|     ", "")
                        high_cves.append(line)
        if " version" in line:
            version_lines.append("  " + line.split(":")[1].strip())
        if "edition" in line:
            edition = line.split(":")[1].strip()

    filtered_lines = list(filter(None, filtered_lines))
    version_lines = sorted(set(filter(None, version_lines)), reverse=True)
    high_cves = sorted(set(filter(None, high_cves)), reverse=True)

    filtered_output = "\n".join(filtered_lines)
    filtered_versions = "\n".join(version_lines)
    filtered_high_cves = "\n".join(high_cves)

    if filtered_high_cves:
        for cve in filtered_high_cves.split("\n"):
            cve_value = cve.strip().split()[0]
            webbrowser.open(f"https://www.google.com/search?q={cve_value}")
            time.sleep(1)

    if filtered_high_cves == "":
        filtered_high_cves = "None"
    else:
        filtered_high_cves = Col.red + filtered_high_cves + Col.endc

    print(f"{Col.green}{'-'*30} OUTPUT:\n{Col.endc}{filtered_output}")
    print(f"{Col.green}{'-'*30} VERSIONS:\n{Col.endc}edition: {edition}\n{filtered_versions}")
    print(f"{Col.green}{'-'*30} HIGH CVES:\n{Col.endc}{filtered_high_cves}")


if __name__ == "__main__":
    main()
