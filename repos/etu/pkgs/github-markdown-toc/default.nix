{
  stdenv,
  lib,
  fetchFromGitHub,
  ...
}: let
  pname = "github-markdown-toc";
  version = "0.8.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ekalinin";
      repo = pname;
      rev = version;
      hash = "sha256-IZ97vxMl0kD/GxibB/4tiucG87wKWpULRVlNARJP5us=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin

      cp -v gh-md-toc $out/bin
      chmod +x $out/bin/gh-md-toc
    '';

    meta = with lib; {
      description = "gh-md-toc: Easy TOC creation for GitHub README.md";
      homepage = "https://github.com/ekalinin/${pname}";
      changelog = "https://github.com/ekalinin/${pname}/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
