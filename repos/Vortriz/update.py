import json
import subprocess

PINNED = [
    "fprintd",
    "libfprint-focaltech-2808-a658-alt",
    "nixos-boot-plymouth-theme",
]

STABLE_RELEASES = [
    "librusty_v8",
    "zotero-better-bibtex",
    "zotero-scipdf",
    "zotero-zotmoov",
]


def determine_packages():
    """
    Determines the list of packages to update.
    If the PACKAGES environment variable is set, it's used.
    Otherwise, it queries the flake for all packages.
    """
    try:
        result = subprocess.run(
            ["nix", "flake", "show", "--all-systems", "--json"],
            capture_output=True,
            text=True,
            check=True,
        )
        flake_info = json.loads(result.stdout)
        packages = []
        if "packages" in flake_info:
            for system_packages in flake_info["packages"].values():
                packages.extend(system_packages.keys())

        # Sort and get unique package names
        return sorted(list(set(packages)))

    except (
        subprocess.CalledProcessError,
        json.JSONDecodeError,
        FileNotFoundError,
    ) as e:
        print(f"Error determining packages: {e}")
        return []


def update_packages(packages, pinned):
    """
    Updates the given packages.
    """
    for package in packages:
        if package in pinned:
            print(f"Package '{package}' is pinned, skipping.")
            continue

        print(f"Updating package '{package}'.")
        try:
            if package in STABLE_RELEASES:
                subprocess.run(
                    ["nix-update", package],
                    stdout=subprocess.DEVNULL,
                    check=True,
                )
            else:
                subprocess.run(
                    ["nix-update", "--version=branch", package],
                    stdout=subprocess.DEVNULL,
                    check=True,
                )
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            print(f"Error updating package '{package}': {e}")


def main():
    """
    Main function to run the update process.
    """
    packages_to_update = determine_packages()
    if packages_to_update:
        update_packages(packages_to_update, PINNED)


if __name__ == "__main__":
    main()
