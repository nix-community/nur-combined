# Adapted from: https://github.com/NixOS/nixpkgs/blob/3e3afe5174c561dee0df6f2c2b2236990146329f/pkgs/by-name/ni/nix-build-uncached/package.nix#L26

{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchpatch2,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "lix-build-uncached";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-build-uncached";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n9Koi01Te77bpYbRX46UThyD2FhCu9OGHd/6xDQLqjQ=";
  };

  patches = [
    # match nix version number only
    (fetchpatch2 {
      url = "https://github.com/bandithedoge/nix-build-uncached/commit/249cad9443dba06299bbe8fe35239f5403e8197f.patch";
      hash = "sha256-3oCELGF4rFffwksPNbzNiibRKcm3ki7rc0K1TecL5+w=";
    })
  ];

  vendorHash = null;

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;

  meta = {
    description = "CI friendly wrapper around nix-build";
    mainProgram = "nix-build-uncached";
    license = lib.licenses.mit;
    homepage = "https://github.com/Mic92/nix-build-uncached";
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
