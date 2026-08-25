{
  writers,
  ...
}:
writers.writePython3Bin "nur-readme-generator"
  {
    # Not the nix flake, but Python's flake8
    flakeIgnore = [
      "E501" # Line too long
    ];
  }
  ''
    import argparse
    import json
    import re
    from pathlib import Path

    SENTINEL_BEGIN = "<!-- BEGIN GENERATED -->"
    SENTINEL_END = "<!-- END GENERATED -->"


    def render_section(data: dict) -> str:
        lines = [SENTINEL_BEGIN, "", "## What this NUR provides", ""]

        # --- Packages ---
        lines.append("### Packages (and overlays)")
        lines.append("")
        packages: list = data.get("packages", [])
        if packages:
            for pkg in sorted(packages, key=lambda p: p["name"]):
                version = f" `{pkg['version']}`" if pkg.get("version") else ""
                description = f" — {pkg['description']}" if pkg.get("description") else ""
                homepage = pkg.get("homepage")
                name = pkg["name"]
                name_part = f"[{name}]({homepage})" if homepage else f"`{name}`"
                lines.append(f"- **{name_part}**{version}{description}")
        else:
            lines.append("_No packages found._")
        lines.append("")

        # --- NixOS Modules ---
        lines.append("### NixOS Modules")
        lines.append("")
        modules: list = data.get("nixosModules", [])
        if modules:
            for mod in sorted(modules):
                lines.append(f"- `{mod}`")
        else:
            lines.append("_No modules found._")
        lines.append("")

        lines.append(SENTINEL_END)
        return "\n".join(lines)


    def update_readme(readme_path: Path, new_section: str) -> None:
        if not readme_path.exists():
            raise FileNotFoundError(f"{readme_path} doesn't exist!")

        original = readme_path.read_text()
        pattern = re.compile(
            rf"{re.escape(SENTINEL_BEGIN)}.*?{re.escape(SENTINEL_END)}",
            re.DOTALL,
        )

        if pattern.search(original):
            updated = pattern.sub(new_section, original)
        else:
            updated = original.rstrip("\n") + f"\n\n{new_section}\n"

        if updated == original:
            print("README already up to date.")
            return

        readme_path.write_text(updated)
        print(f"Updated {readme_path}")


    def main() -> None:
        parser = argparse.ArgumentParser()
        parser.add_argument("--meta", help="Path to the built nur-meta.json")
        parser.add_argument("--readme", default="README.md")
        parser.add_argument("--dry-run", action="store_true")
        args = parser.parse_args()

        data = json.loads(Path(args.meta).read_text())

        section = render_section(data)

        if args.dry_run:
            print(section)
            return

        update_readme(Path(args.readme), section)


    if __name__ == "__main__":
        main()
  ''
