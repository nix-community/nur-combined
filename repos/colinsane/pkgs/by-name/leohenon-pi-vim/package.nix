{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-vim";
  version = "0.1.4-unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "leohenon";
    repo = "pi-vim";
    rev = "819a8b0f0a1ec2171dffd9528636dcae7ce35e70";
    hash = "sha256-RrYpmKsnUoEdCgVIubNs9l//wVBP36oU2TjN0NWlmAo=";
    # upstream omits the integrity hashes for pi-* dependencies, expecting pi to already be present.
    # patch out the deps onto pi *here*, so that nix-update-script can generate a correct lockfile.
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-coding-agent": /d' \
        -e '/"@earendil-works\/pi-tui": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-LY4C/JwNZZks/OcZr4Kb1TLRhEBbbeVY71ThO1Kdd4A=";

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/@leohenon/pi-vim/* $out
    rmdir $out/lib/node_modules/@leohenon/pi-vim
    rmdir $out/lib/node_modules/@leohenon
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vim mode for pi with motions, text objects, and visual mode.";
    homepage = "https://github.com/leohenon/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
