{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenv lib obs-studio fftwFloat pkg-config cmake;
in
  stdenv.mkDerivation rec {
    pname = "advanced-masks";
    version = "1.1.0";

    src = lib.fetchFromGitHub {
      fetchSubmodules = true;
      owner = "FiniteSingularity";
      repo = "obs-advanced-masks";
      rev = "v${version}";
      sha256 = "sha256-NcBtj+5X9tPH853a6oXzQCBH26hx8Yt17WjP9ryvgmc=";
    };

    nativeBuildInputs = [cmake pkg-config];

    postFixup = ''
      mkdir -p $out/lib $out/share/obs/obs-plugins
      mv $out/${pname}/bin/64bit $out/lib/obs-plugins
      mv $out/${pname}/data $out/share/obs/obs-plugins/${pname}
      rm -rf $out/${pname}
    '';

    buildInputs = [
      obs-studio
      fftwFloat
    ];

    meta = {
      description = "Expanded masking functionality for OBS";
      homepage = "https://github.com/FiniteSingularity/obs-advanced-masks";
      maintainers = [];
      license = lib.licenses.gpl3;
      platforms = ["x86_64-linux"];
    };
  }
