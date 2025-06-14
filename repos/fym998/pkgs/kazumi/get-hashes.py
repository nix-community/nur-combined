import yaml
from pathlib import Path
import subprocess
import json
from multiprocessing import Pool


def prefetch_git(package_desc):
    package, description = package_desc
    url = description["url"]
    rev = description["resolved-ref"]
    result = subprocess.run(
        [
            "nix-prefetch-git",
            "--url",
            url,
            "--rev",
            rev,
        ],
        capture_output=True,
        text=True,
    ).stdout.strip()
    print(f"Fetched {package} from {url} at {rev}")
    print(f"{result}\n")
    return f'"{package}" = "{json.loads(result)["hash"]}";'


pubspec_lock_content = Path("pubspec.lock").read_text(encoding="utf-8")
pubspec_lock = yaml.load(pubspec_lock_content, yaml.CLoader)
git_packages = list(
    map(
        lambda k: (k, pubspec_lock["packages"][k]["description"]),
        filter(
            lambda k: pubspec_lock["packages"][k].get("source") == "git",
            pubspec_lock["packages"],
        ),
    )
)

if __name__ == "__main__":
    with Pool() as pool:
        results = pool.map(prefetch_git, git_packages)
        for result in results:
            print(result)
