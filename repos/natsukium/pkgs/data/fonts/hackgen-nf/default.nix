{ lib, fetchzip }:

let
  version = "2.7.1";
in
  fetchzip {
    name = "HackGen-NF-${version}";
    url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGen_NF_v${version}.zip";
    postFetch = ''
      install -Dm644 $out/*.ttf -t $out/share/fonts/hackgen-nf
      shopt -s extglob dotglob
      rm -rf $out/!(share)
      shopt -u extglob dotglob
    '';
    sha256 = "sha256-9sylGr37kKIGWgThZFqL2y6oI3t2z4kbXYk5DBMIb/g=";

    meta = with lib; {
      description = "compoite font of Hack and GenJyuu-Gothic";
      homepage = "https://github.com/yuru7/HackGen";
      license = licenses.ofl;
      platforms = platforms.unix;
    };
  }
