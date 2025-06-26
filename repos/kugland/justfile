# Format the Nix code in the repository.
format:
    just --unstable --fmt
    nix shell nixpkgs#nixpkgs-fmt -c nixpkgs-fmt .

update-cursor:
    #! /usr/bin/env bash
    x86_64_url="$(curl -I https://www.cursor.com/download/stable/linux-x64 | sed '/^location: /{s///; s/\s*//g;p}; d')"
    aarch64_url="$(curl -I https://www.cursor.com/download/stable/linux-arm64 | sed '/^location: /{s///; s/\s*//g;p}; d')"
    version="$(echo "$x86_64_url" | sed 's/.*\/Cursor-\(.*\)-x86_64\.AppImage/\1/')"
    x86_64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$x86_64_url"))"
    aarch64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$aarch64_url"))"
    echo "x86_64_url: $x86_64_url"
    echo "aarch64_url: $aarch64_url"
    echo "version: $version"
    sed -i -Ee '
            /^(\s*x86_64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_url}"'";|g;
            /^(\s*x86_64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_hash}"'";|g;
            /^(\s*aarch64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_url}"'";|g;
            /^(\s*aarch64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_hash}"'";|g;
            /^(\s*version)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${version}"'";|g;
        ' pkgs/cursor/default.nix
