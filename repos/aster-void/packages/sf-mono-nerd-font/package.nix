# https://github.com/epk/SF-Mono-Nerd-Font
# Source License: None
{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}: let
  version = "v18.0d1e1.0";
in
  stdenvNoCC.mkDerivation {
    pname = "sf-mono-nerd-font";
    inherit version;

    src = fetchFromGitHub {
      owner = "epk";
      repo = "SF-Mono-Nerd-Font";
      tag = version;
      hash = "sha256-f5A/vTKCUxdMhCqv0/ikF46tRrx5yZfIkvfExb3/XEQ=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/opentype
      cp *.otf $out/share/fonts/opentype/

      runHook postInstall
    '';

    meta = {
      homepage = "https://github.com/epk/SF-Mono-Nerd-Font";
      description = "Apple's SF Mono font patched with the Nerd Fonts patcher";
      # Owner doesn't specify license
      maintainers = [];
      platforms = lib.platforms.all;
    };
  }
