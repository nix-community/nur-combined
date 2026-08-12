{
  stdenv,
  sources,
  lib,
  meson,
  pkg-config,
  ninja,
  libva,
  libdrm,
  gst_all_1,
  udev,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.libva-v4l2) pname version src;
  postPatch = ''
    sed -i "s/run_command(\['git', 'rev-parse', '--short', 'HEAD'\], check: true).stdout().strip()/'${finalAttrs.version}'/" meson.build
    cat meson.build
  '';
  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];
  buildInputs = [
    libva
    libdrm
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    udev
  ];
  meta = with lib; {
    description = "V4L2 libVA Backend";
    homepage = "https://github.com/mxsrc/libva-v4l2";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with maintainers; [ yinfeng ];
  };
})
