# Bump every pkgs/<name> with nix-update; `-u` runs passthru.updateScript
# instead when the package defines one. `nix flake check` builds the result.
#
# --use-github-releases: the releases.atom feed also lists bare tags, which
# upstreams push before their release assets exist (404 on fetch).
failed=()
for dir in pkgs/*/; do
  pkg="$(basename "$dir")"
  nix-update --flake --use-github-releases --use-update-script "$pkg" || failed+=("$pkg")
done

if ((${#failed[@]})); then
  echo "update failed: ${failed[*]}" >&2
  exit 1
fi
