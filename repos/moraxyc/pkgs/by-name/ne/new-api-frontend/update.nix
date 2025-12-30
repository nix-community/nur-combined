{
  writeShellApplication,
  nix-update,
  common-updater-scripts,
  prefetch-npm-deps,
  sd,
}:

writeShellApplication {
  name = "update-new-api-frontend";
  runtimeInputs = [
    common-updater-scripts
    nix-update
    prefetch-npm-deps
    sd
  ];

  text = ''
    nix-update new-api-frontend --version=skip --generate-lockfile

    if ! git diff --exit-code pkgs/by-name/ne/new-api-frontend/package-lock.json > /dev/null; then
      prev_npm_hash=$(nix-instantiate . --eval --json -A new-api-frontend.npmDepsHash | jq -r .)
      new_npm_hash=$(prefetch-npm-deps pkgs/by-name/ne/new-api-frontend/package-lock.json)
      sed -i "s|$prev_npm_hash|$new_npm_hash|" pkgs/by-name/ne/new-api-frontend/package.nix
    fi
  '';
}
