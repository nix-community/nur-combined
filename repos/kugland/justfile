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
    #! nix-shell -i bash -p curl htmlq
    x86_64_url="$(curl -sSL 'https://cursor.com/download' | htmlq 'a[href$=".AppImage"]' -a href | grep -F 'x86_64' | head -1)"
    aarch64_url="$(curl -sSL 'https://cursor.com/download' | htmlq 'a[href$=".AppImage"]' -a href | grep -F 'aarch64' | head -1)"
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
    version="$(echo "$x86_64_url" | sed 's/.*\/MuseScore-Studio-\(.*\)-x86_64\.AppImage/\1/')"
    x86_64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$x86_64_url"))"
    aarch64_hash="$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url "$aarch64_url"))"
    sed -i -Ee '
            /^(\s*x86_64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_url}"'";|g;
            /^(\s*x86_64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${x86_64_hash}"'";|g;
            /^(\s*aarch64[.]url)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_url}"'";|g;
            /^(\s*aarch64[.]hash)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${aarch64_hash}"'";|g;
            /^(\s*version)\s*=\s*"[^"]+"\s*;\s*$/s||\1 = "'"${version}"'";|g;
    ' pkgs/musescore/default.nix

# Update upstream git repos referenced in the config.
update-adblock:
    #! /usr/bin/env nix-shell
    #! nix-shell -i bash -p update-nix-fetchgit
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
      echo "Error: There are uncommitted changes in the working directory." >&2
      exit 1
    fi
    update-nix-fetchgit --only-commented ./modules/adblock.nix
    git add ./modules/adblock.nix
    git commit --no-gpg-sign -m 'Adblock upstream source updated'
