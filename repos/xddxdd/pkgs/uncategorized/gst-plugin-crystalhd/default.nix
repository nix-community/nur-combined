{
  stdenv,
  lib,
  sources,
  pkg-config,
  libcrystalhd,
  gst_all_1,
}:
stdenv.mkDerivation rec {
  pname = "gst-plugin-crystalhd";
  inherit (sources.crystalhd-ubuntu) version src;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libcrystalhd
    gst_all_1.gstreamer
    gst_all_1.gstreamermm
  ];

  postPatch = ''
    cd filters/gst/gst-plugin

    substituteInPlace autogen.sh \
      --replace-fail "/usr/include/libcrystalhd" "${libcrystalhd}/include/libcrystalhd"
    substituteInPlace src/Makefile.am \
      --replace-fail "/usr/include/libcrystalhd" "${libcrystalhd}/include/libcrystalhd"
    substituteInPlace src/Makefile.in \
      --replace-fail "/usr/include/libcrystalhd" "${libcrystalhd}/include/libcrystalhd"
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Broadcom Crystal HD Hardware Decoder (BCM70012/70015) GStreamer plugin";
    homepage = "https://launchpad.net/ubuntu/+source/crystalhd";
    license = lib.licenses.unfreeRedistributable;
  };
}
