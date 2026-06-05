# this package is based on:
# - <https://github.com/nix-community/nur-combined/blob/85aacb5396a4c6e8eccdcf9f17bff891f9be712e/repos/binarycat/pkgs/by-name/nixpkgs-whereis/package.nix>
{
  coreutils,
  fetchFromGitea,
  fish,
  lib,
  makeWrapper,
  nix,
  stdenv,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nixpkgs-whereis";
  version = "1.2.3";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "nixpkgs-whereis";
    tag = finalAttrs.version;
    hash = "sha256-CZokiob077hNf/ipKWQL1bo+8dXoLcpT748xFoQRMbI=";
  };
  # upstream source doesn't seem to fetch
  # src = fetchFromGitea {
  #   domain = "git.envs.net";
  #   owner = "binarycat";
  #   repo = "nixpkgs-whereis";
  #   rev = finalAttrs.version;
  #   tag = finalAttrs.version;
  #   hash = "sha256-CZokiob077hNf/ipKWQL1bo+8dXoLcpT748xFoQRMbI=";
  # };

  nativeBuildInputs = [
    coreutils
    fish
    makeWrapper
    nix
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postFixup = ''
    patchShebangs $out/bin/nixpkgs-whereis
    wrapProgram $out/bin/nixpkgs-whereis \
      --prefix PATH : ${lib.makeBinPath [ nix coreutils fish ]}
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "nixpkgs-whereis --version";
    inherit (finalAttrs) version;
  };

  meta = {
    description = "A simple command to check where in nixpkgs an attribute is defined";
    homepage = "https://git.envs.net/binarycat/nixpkgs-whereis";
  };
})
