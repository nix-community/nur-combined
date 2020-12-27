{ stdenv, fetchurl, xorg, libGL, zlib, libgpgerror, glib, fontconfig, libdrm, autoPatchelfHook }:

stdenv.mkDerivation rec {
  name = "chitubox-${version}";
  version = "1.7.0";

  src = fetchurl {
    url =
      "https://sac.chitubox.com/software/download.do?softwareId=17839&softwareVersionId=v${version}&fileName=CHITUBOX_V${version}.tar.gz";
    name = "${name}.tar.gz";
    sha256 = "0i842fw73vclzlc8mzjq47j6c9jf4qi7azwrj2mmcgpawjy4sv7d";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ xorg.libX11 stdenv.cc.cc.lib libGL zlib libgpgerror glib fontconfig libdrm];

  installPhase = ''
    cp -r ./ $out
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.chitubox.com";
    description = "SLA/DLP/LCD 3D printing slicer";
    platforms = platforms.linux;
    license = licenses.unfreeRedistributable;
    maintainers = [ "chris@oboe.email" ];
  };
}

