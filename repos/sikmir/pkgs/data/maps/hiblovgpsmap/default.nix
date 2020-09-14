{ stdenvNoCC, lib, fetchgdrive, unzip }:
let
  version = "2020-09-06";
  filename = "OV-Hib-Lov-${lib.replaceStrings [ "-" ] [ "" ] version}-1.01.zip";
in
stdenvNoCC.mkDerivation {
  pname = "hiblovgpsmap";
  inherit version;

  src = fetchgdrive {
    id = "1KVgabpxNVbH_xsaCsEAsbRP8XkHHPj78";
    sha256 = "087h1chr7z936lhkxhp8p46f7wynh0zmjp0sr97v802hz3k7h232";
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
