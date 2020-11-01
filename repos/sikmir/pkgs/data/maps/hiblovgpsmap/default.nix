{ stdenvNoCC, lib, fetchgdrive, unzip }:
let
  version = "2020-10-17";
  filename = "OV-Hib-Lov-${lib.replaceStrings [ "-" ] [ "" ] version}-1.03.zip";
in
stdenvNoCC.mkDerivation {
  pname = "hiblovgpsmap";
  inherit version;

  src = fetchgdrive {
    id = "17DUaRG_qj_qgIZ5EuHOflaDCobO0pWlv";
    sha256 = "1dmc02jg6pgqz05s61qwym4dgwx1qb43j0capzsaiyzbq9m4z99d";
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
