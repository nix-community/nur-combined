{ stdenv
, fetchurl
, p7zip
}:

stdenv.mkDerivation rec {
  pname = "vmangos-worlddb";
  version = "2020-11-12";

  src = fetchurl {
    url = "https://github.com/brotalnia/database/blob/master/world_full_12_november_2020.7z?raw=true";
    sha256 = "1ilpqw2wi2pl9v8yhvzpnl4cg32pxg1xx9q836nwykfq4qi40hpl";
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

  meta = with stdenv.lib; {
    description = "Vanilla MaNGOS world database";
    homepage = "https://github.com/brotalnia/database";
  };
}
