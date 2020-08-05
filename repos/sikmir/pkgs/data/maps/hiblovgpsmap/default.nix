{ stdenvNoCC, lib, fetchgdrive, unzip }:
let
  version = "2019-10-28";
  filename = "OV-Hib-Lov-${lib.replaceStrings [ "-" ] [ "" ] version}-1.02.zip";
in
stdenvNoCC.mkDerivation {
  pname = "hiblovgpsmap";
  inherit version;

  src = fetchgdrive {
    id = "10aAOKY8U7TQvFvuWBkwTei9iP3-cUvoE";
    sha256 = "1079bn8rkdfsbqivxkm3zi327k2i4k5p20rr2jw7gacfsvdk4954";
    name = filename;
  };

  unpackPhase = "${unzip}/bin/unzip $src";

  installPhase = "install -Dm644 *.img -t $out";

  preferLocalBuild = true;

  meta = with lib; {
    description = "Detailed map of Khibins and Lovozero for GPS";
    homepage = "https://vk.com/hiblovgpsmap";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
