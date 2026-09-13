{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "nix-package-runner";
  version = "0-unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "iahccc";
    repo = "NixPackageRunner";
    rev = "829ad93c15b7c0ec82a6d7483728029037442601";
    hash = "sha256-ur+1oN+QmTu7p5ZMpL3rCd4JGYbkerko4twa+tH6uvg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin for searching and running nixpkgs packages";
    homepage = "https://github.com/iahccc/NixPackageRunner";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
