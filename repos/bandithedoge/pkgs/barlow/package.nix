{
  fetchFromGitHub,
  lib,
  stdenv,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "barlow";
  version = "1.422-unstable-2024-08-10";
  src = fetchFromGitHub {
    owner = "jpt";
    repo = "barlow";
    rev = "2ca33194d753691df200902b9073f917ad4d54d1";
    hash = "sha256-X7bPcL6/KxpDSoa5YZkwoDGsEodw8hbgt6dxMh+VlaI=";
  };

  buildPhase = ''
    mkdir -p $out/share/fonts/{truetype,opentype,woff2}
    cp -r fonts/ttf/*.ttf $out/share/fonts/truetype
    cp -r fonts/otf/*.otf $out/share/fonts/opentype
    cp -r fonts/ttf/*.woff2 $out/share/fonts/woff2
  '';

  passthru = {
    _ignoreDupe = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch=1.5"
      ];
    };
  };

  meta = {
    description = "Straight-sided sans-serif superfamily";
    homepage = "https://tribby.com/fonts/barlow";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
