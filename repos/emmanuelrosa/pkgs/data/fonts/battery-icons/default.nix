{ stdenv, lib, fetchurl, unzip }:

let
  description = "Battery Icons";
in stdenv.mkDerivation rec {
  name = "battery-icons-${version}";
  version = "2020-01-26";

  src = fetchurl {
    url = "https://dl.dafont.com/dl/?f=battery_icons";
    name = "battery-icons.zip";
    sha256 = "18w4fp9xhvs34dv92ay918wl81ffjw3wcva84m6gpm1jcfqww292";
  };

  nativeBuildInputs = [ unzip ];

  unpackCmd = ''
    mkdir battery-icons
    pushd battery-icons
    unzip $curSrc
    popd
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/battery-icons

    cp "Battery Icons.otf" $out/share/fonts/battery-icons/battery-icons.otf
  '';

  meta = with lib; {
    inherit description;
    homepage = https://www.dafont.com;
    license = licenses.free;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
