# Format the Nix code in the repository.
format:
    just --unstable --fmt
    nix shell nixpkgs#nixpkgs-fmt -c nixpkgs-fmt .

update:
    #! /usr/bin/env nix-shell
    #! nix-shell -i bash -p parallel
    parallel just ::: update-flakes update-cursor update-musescore

update-flakes:
    nix flake update

update-cursor:
    #! /usr/bin/env nix-shell
    #! nix-shell -i bash -p curl
    x86_64_url="$(curl -I https://www.cursor.com/download/stable/linux-x64 | sed '/^location: /{s///; s/\s*//g;p}; d')"
    aarch64_url="$(curl -I https://www.cursor.com/download/stable/linux-arm64 | sed '/^location: /{s///; s/\s*//g;p}; d')"
    version="$(echo "$x86_64_url" | sed 's/.*\/Cursor-\(.*\)-x86_64\.AppImage/\1/')"
    x86_64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$x86_64_url"))"
    aarch64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$aarch64_url"))"
    sed -i -Ee '
            /^(\s*x86_64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_url}"'";|g;
            /^(\s*x86_64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_hash}"'";|g;
            /^(\s*aarch64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_url}"'";|g;
            /^(\s*aarch64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_hash}"'";|g;
            /^(\s*version)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${version}"'";|g;
        ' pkgs/cursor/default.nix

update-musescore:
    #! /usr/bin/env nix-shell
    #! nix-shell -i bash -p gh
    x86_64_url="$(gh release -R musescore/MuseScore view $(gh release -R musescore/MuseScore list --json tagName,isLatest --jq 'map(select(.isLatest == true)) | .[] | .tagName') --json assets --jq '.assets | .[] | .url' | grep -- '-x86_64[.]AppImage$')"
    aarch64_url="$(gh release -R musescore/MuseScore view $(gh release -R musescore/MuseScore list --json tagName,isLatest --jq 'map(select(.isLatest == true)) | .[] | .tagName') --json assets --jq '.assets | .[] | .url' | grep -- '-aarch64[.]AppImage$')"
    armv7l_url="$(gh release -R musescore/MuseScore view $(gh release -R musescore/MuseScore list --json tagName,isLatest --jq 'map(select(.isLatest == true)) | .[] | .tagName') --json assets --jq '.assets | .[] | .url' | grep -- '-armv7l[.]AppImage$')"
    version="$(echo "$x86_64_url" | sed 's/.*\/MuseScore-\(.*\)-x86_64\.AppImage/\1/')"
    x86_64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$x86_64_url"))"
    aarch64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$aarch64_url"))"
    armv7l_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$armv7l_url"))"
    sed -i -Ee '
            /^(\s*x86_64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_url}"'";|g;
            /^(\s*x86_64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_hash}"'";|g;
            /^(\s*aarch64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_url}"'";|g;
            /^(\s*aarch64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_hash}"'";|g;
            /^(\s*armv7l[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${armv7l_url}"'";|g;
            /^(\s*armv7l[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${armv7l_hash}"'";|g;
            /^(\s*version)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${version}"'";|g;
    ' pkgs/musescore/default.nix
