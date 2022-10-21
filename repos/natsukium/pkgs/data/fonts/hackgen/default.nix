{ lib, fetchzip }:

let
  version = "2.7.1";
in
  fetchzip {
    name = "HackGen-${version}";
    url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGen_v${version}.zip";
    postFetch = ''
      install -Dm644 $out/*.ttf -t $out/share/fonts/hackgen
      shopt -s extglob dotglob
      rm -rf $out/!(share)
      shopt -u extglob dotglob
    '';
    sha256 = "sha256-UL6U/q2u1UUP31lp0tEnFjzkn6dn8AY6hk5hJhPsOAE=";

    meta = with lib; {
      description = "composite font of Hack and GenJyuu-Gothic";
      homepage = "https://github.com/yuru7/HackGen";
      license = licenses.ofl;
      platforms = platforms.unix;
    };
  }
