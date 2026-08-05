{
  lib,
  fetchFromGitLab,
  python3,
  nix-update-script,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mkbstosi";
  version = "0-unstable-2026-01-03";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "freedesktop-sdk";
    repo = "mkbstosi";
    rev = "69453423441de93aa18ae4e81c0655e42b39835c";
    hash = "sha256-yaH5CDg3+egI24orAgZyezoRKIrOTegm6J12codLP4M=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    ruamel-yaml
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Make BuildStream OS Image";
    homepage = "https://gitlab.com/freedesktop-sdk/mkbstosi";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
})
