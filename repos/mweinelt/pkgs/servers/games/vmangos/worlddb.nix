{ stdenv
, lib
, fetchurl
, p7zip
}:

stdenv.mkDerivation rec {
  pname = "vmangos-worlddb";
  version = "2021-06-14";

  src = fetchurl {
    url = "https://github.com/brotalnia/database/blob/master/world_full_14_june_2021.7z?raw=true";
    hash = "sha256:04j2iipjd4h811lbxjiy398a4cwrc27kdfi8wfmrv6ndvqz0l12n";
  };

  phases = [ "unpackPhase" "installPhase" ];

  unpackPhase = ''
    ${p7zip}/bin/7z x ${src}
  '';

  installPhase = ''
    mkdir $out
    cp *.sql $out/
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Vanilla MaNGOS world database";
    homepage = "https://github.com/brotalnia/database";
  };
}
