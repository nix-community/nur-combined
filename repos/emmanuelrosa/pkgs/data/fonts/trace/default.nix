{ stdenv, lib, fetchurl, unzip }:

let
  description = "Trace font";
in stdenv.mkDerivation rec {
  pname = "trace-font";
  version = "2020-03-25";

  src = fetchurl {
    url = https://get.fontspace.co/download/family/194l/f3bb2d1221f04e149a022c65a84b5563/trace-font.zip;
    sha256 = "1nxfzhndnw8pm4qzibhma1m7knmgf6bvzcn75scknysh9vd5w42y";
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
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
