To add/update gradle.lock:

- clone the source, make sure its writable
- `nix run ~/dev/nix-stuff#qb.<pkgname>.gradle2nix`
- `cp gradle.lock ~/dev/nix-stuff/androidPackages/<pkgname>/`

when gradle wants to grab from github maven repos
(https://maven.pkg.github.com/) it needs auth:

- in source clone:
  `printf 'gitHubToken=%s' "$(nix run ~/dev/nix-stuff#sops -- decrypt --extract '["token"]' ~/dev/nix-stuff/secrets/misc/github-pat-for-repos.yaml)" > user.properties`
- run gradle2nix
- when building, pass the token to the daemon:
  `nix build --option impure-env "GITHUB_TOKEN=$GITHUB_TOKEN" ...`
