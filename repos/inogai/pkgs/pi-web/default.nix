# pi-web: Web UI for persistent Pi Coding Agent sessions in real workspaces.
# Built from source (the NUR norm): tsc + vite build, node-pty compiled
# against the nix nodejs. Peer dependencies (@earendil-works/pi-coding-agent
# etc.) are pulled in by npm, so the `pi` binary comes along for free.
# integrity.patch: upstream's package-lock.json omits `integrity` on three
# nested peer deps of pi-coding-agent, which fetchNpmDeps' parser rejects.
{ lib, buildNpmPackage, fetchFromGitHub, fetchNpmDeps, nodejs_22, python3, applyPatches }:
let
  src0 = fetchFromGitHub {
    owner = "jmfederico";
    repo = "pi-web";
    rev = "v1.202608.0";
    hash = "sha256-86OnGL+K6Y/EPRziQ1CMfX2kafqhOWb2auX+5yViatI=";
  };
  src = applyPatches {
    src = src0;
    patches = [
      ./integrity.patch
      # pi-web-server imports @earendil-works/pi-* at runtime (peer deps), so
      # they must survive npm prune: move them from devDependencies to
      # dependencies (upstream's container does --omit=dev --include=peer).
      ./peers-package-json.patch
      ./peers-lockfile.patch
    ];
  };
in
buildNpmPackage rec {
  pname = "pi-web";
  version = "1.202608.0";

  inherit src;

  nodejs = nodejs_22;

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-n399bP48bp8JNWzroftJNc35AYUjhpIi/7Qpl/3ylKE=";
  };

  # node-pty (runtime dep) compiles against the nix nodejs during npm rebuild.
  nativeBuildInputs = [ python3 ];

  # npm's cacache index.compact needs write access (lock file); the npmDeps
  # store is read-only, so requests that take the make-fetch-happen path
  # (e.g. peer deps) fail with ENOTCACHED. Copy the cache to a writable dir.
  makeCacheWritable = true;

  meta = with lib; {
    description = "Web UI for persistent Pi Coding Agent sessions in real workspaces";
    homepage = "https://pi-web.dev";
    license = licenses.mit;
  };
}
