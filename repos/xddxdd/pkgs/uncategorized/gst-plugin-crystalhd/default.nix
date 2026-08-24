{
  fetchgit,
  stdenv,
  lib,
  pkg-config,
  libcrystalhd,
  gst_all_1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gst-plugin-crystalhd";
  version = "0-unstable-2020-03-22";
  src = fetchgit {
    url = "https://git.launchpad.net/ubuntu/+source/crystalhd";
    rev = "72237253de7901c70aa666b3e022289f1ebae0ac";
    fetchSubmodules = false;
    hash = "sha256-84eztV9ExTP9a/L1qpp8uyQJgF6aFVRe52bCje18JOY=";
  };
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
    platforms = [ "x86_64-linux" ];
  };
})
