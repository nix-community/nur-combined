{ stdenv, lib, fetchurl, unzip }:

let
  description = "Trace font";
in stdenv.mkDerivation rec {
  pname = "trace-font";
  version = "2020-10-07";

  src = fetchurl {
    url = https://get.fontspace.co/download/family/194l/f3bb2d1221f04e149a022c65a84b5563/trace-font.zip;
    sha256 = "1ji0q8ggbpxqmz5c0kkhvb5fm2iz02p5a9fj81kbl2qqpn0ii7vm";
  };

  nativeBuildInputs = [ unzip ];

  unpackCmd = ''
    mkdir ${pname}
    pushd ${pname}
    unzip $curSrc
    chmod ug+r *
    popd
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/trace
    cp -r ./*.ttf $out/share/fonts/trace
  '';

  meta = with lib; {
    inherit description;
    homepage = https://www.fontspace.com/trace-font-f3625;
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
