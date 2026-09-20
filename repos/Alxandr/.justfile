[private]
@list:
    just --list

# Generate a crate2nix Cargo.json from a GitHub repository at an exact ref.
generate-cargo-json repository directory:
    #!/usr/bin/env bash
    set -euo pipefail

    repository={{ quote(repository) }}
    directory={{ quote(directory) }}

    if [[ ! "$repository" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+:[A-Za-z0-9._/-]+$ ]]; then
      echo "Repository must have the form owner/repo:ref." >&2
      exit 2
    fi

    if [[ ! "$directory" =~ ^[A-Za-z0-9._+/-]+$ ]] || [[ "/$directory/" == *"/../"* ]]; then
      echo "Directory must be a relative path below pkgs/." >&2
      exit 2
    fi

    packageDir="$PWD/pkgs/$directory"
    if [[ ! -f "$packageDir/package.nix" ]]; then
      echo "Package file does not exist: $packageDir/package.nix" >&2
      exit 2
    fi

    githubRepository=${repository%%:*}
    gitRef=${repository#*:}
    tmpDir=$(mktemp -d)
    trap 'rm -rf "$tmpDir"' EXIT

    mkdir "$tmpDir/source"
    git -C "$tmpDir/source" init --quiet
    git -C "$tmpDir/source" remote add origin "https://github.com/$githubRepository.git"
    git -C "$tmpDir/source" fetch --quiet --depth 1 --no-tags origin "$gitRef"
    git -C "$tmpDir/source" checkout --quiet --detach FETCH_HEAD

    crate2nix="$(nix-build . -A crate2nix --no-out-link)/bin/crate2nix"
    (
      cd "$tmpDir/source"
      "$crate2nix" generate \
        --cargo-toml Cargo.toml \
        --output Cargo.json \
        --format json
    )

    cp "$tmpDir/source/Cargo.json" "$packageDir/Cargo.json"
    echo "Generated $packageDir/Cargo.json"

# Generate the NuGet dependency file for a buildDotnetModule package.
generate-nuget-deps package:
    #!/usr/bin/env bash
    set -euo pipefail

    package={{ quote(package) }}
    fetchDeps=$(nix-build . -A "$package.fetch-deps" --no-out-link)
    "$fetchDeps"
