{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "hiblovgpsmap";
  version = "2019-10-28";

  src = fetchurl {
    url = "https://drive.google.com/uc?export=download&id=10aAOKY8U7TQvFvuWBkwTei9iP3-cUvoE";
    sha256 = "1079bn8rkdfsbqivxkm3zi327k2i4k5p20rr2jw7gacfsvdk4954";
    name = "OV-Hib-Lov-${stdenv.lib.replaceStrings ["-"] [""] version}-1.02.zip";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = "unzip $src";

  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;

  installPhase = ''
    install -Dm644 *.img -t "$out/share/gpxsee/maps"
  '';

  meta = with stdenv.lib; {
    description = "Detailed map of Khibins and Lovozero for GPS";
    homepage = "https://vk.com/hiblovgpsmap";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
