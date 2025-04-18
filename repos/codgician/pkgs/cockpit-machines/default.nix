# Modified based on https://github.com/NixOS/nixpkgs/pull/357323
# Thanks to lucasew

{
  lib,
  stdenv,
  cockpit,
  nodejs,
  gettext,
  writeShellScriptBin,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cockpit-machines";
  version = "329";

  src = fetchFromGitHub {
    owner = "cockpit-project";
    repo = "cockpit-machines";
    rev = "refs/tags/${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-h60l8X9fklKSUCGIaEcnHzEcl2eBAChdIhqn7KjcR9s=";

    postFetch = ''
      cp $out/node_modules/.package-lock.json $out/package-lock.json
    '';
  };

  nativeBuildInputs = [
    (writeShellScriptBin "git" "true")
    nodejs
    gettext
  ];

  cockpitSrc = cockpit.src;

  postPatch = ''
    mkdir -p pkg; cp -r $cockpitSrc/pkg/lib pkg
    mkdir -p test; cp -r $cockpitSrc/test/common test

    substituteInPlace Makefile \
      --replace-fail '$(MAKE) package-lock.json' 'true' \
      --replace-fail '$(COCKPIT_REPO_FILES) | tar x' "" \
      --replace-fail '/usr/local' "$out"
    patchShebangs build.js
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cockpit UI for virtual machines";
    homepage = "https://github.com/cockpit-project/cockpit-machines";
    changelog = "https://github.com/cockpit-project/cockpit-machines/releases/tag/${finalAttrs.version}";
    license = [ lib.licenses.lgpl21 ];
    maintainers = [ lib.maintainers.codgician ];
  };
})
