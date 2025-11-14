import json
import tomllib
from pathlib import Path

from py_markdown_table.markdown_table import markdown_table


def main():
    repo_root = Path(__file__).parent
    nvfetcher_path = repo_root / "nvfetcher.toml"
    sources_path = repo_root / "_sources/generated.json"
    readme_path = repo_root / "README.md"

    with open(nvfetcher_path, "rb") as f:
        packages = tomllib.load(f)

    with open(sources_path, "r") as f:
        sources = json.load(f)

    package_names = sorted(packages.keys())

    table_data = []
    for name in package_names:
        pkg = sources[name]
        date = pkg["date"]
        version = pkg["version"]
        src = pkg["src"]

        if src["type"] == "github":
            link = f"https://github.com/{src['owner']}/{src['repo']}"
            last_updated = date
        elif src["type"] == "url":
            link = src["url"]
            last_updated = f"Pinned to {version}"

        table_data.append(
            {"Package": f"[`{name}`]({link})", "Last Updated": last_updated}
        )

    table = (
        markdown_table(table_data)
        .set_params(row_sep="markdown", quote=False, padding_width=4)
        .get_markdown()
    )

    with open(readme_path, "r") as f:
        readme_content = f.read()

    start_marker = "<!-- PACKAGES_START -->"
    end_marker = "<!-- PACKAGES_END -->"

    start_index = readme_content.find(start_marker) + len(start_marker)
    end_index = readme_content.find(end_marker)
    new_readme = (
        readme_content[:start_index] + "\n" + table + "\n" + readme_content[end_index:]
    )

    with open(readme_path, "w") as f:
        f.write(new_readme)


if __name__ == "__main__":
    main()
