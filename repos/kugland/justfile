# Format the Nix code in the repository.
format:
    just --unstable --fmt
    nix-shell -p alejandra --run "alejandra ."

update-qemu-user-static:
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p jq -p skopeo -p nix-prefetch-docker
    set -euo pipefail
    CURRENT_DIGEST="$(sed -nE '/imageDigest = /s/.*"(sha256:[0-9a-f]{64})".*/\1/p' < ./modules/qemu-user-static.nix)"
    DIGEST="$(skopeo inspect docker://docker.io/multiarch/qemu-user-static:latest | jq -r ".Digest")"
    if [ "$CURRENT_DIGEST" != "$DIGEST" ]; then
      echo "Updating qemu-user-static to $DIGEST"
      NEW_SHA256="$(nix-prefetch-docker --image-name docker.io/multiarch/qemu-user-static --image-tag latest --json | jq -r '.sha256')"
      NEW_SHA256="sha256-$(nix-hash --type sha256 --to-base64 "$NEW_SHA256")"
      sed -Ei "
        /imageDigest = .*/s//imageDigest = \"$DIGEST\";/;
        /sha256 = .*/s//sha256 = \"$NEW_SHA256\";/;
      " modules/qemu-user-static.nix
    else
      echo "qemu-user-static is already up-to-date"
    fi
