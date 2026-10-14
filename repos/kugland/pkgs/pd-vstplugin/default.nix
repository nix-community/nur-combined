{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchFromGitHub,
  cmake,
  puredata,
  libX11,
}:
let
  # Free reimplementation of the (discontinued, unfree) Steinberg VST2 SDK headers.
  fst = fetchFromGitLab {
    domain = "git.iem.at";
    owner = "zmoelnig";
    repo = "FST";
    tag = "v0.177.0";
    hash = "sha256-Ofnl6qsbGseYomfQDn7UZ0wmxafle+PSAsZNYqGhv14=";
  };

  vst3-pluginterfaces = fetchFromGitHub {
    owner = "steinbergmedia";
    repo = "vst3_pluginterfaces";
    tag = "v3.8.1_build_84";
    hash = "sha256-Ey9+zHhsVuj9bqmBqCOQ/Ls6uwYcOzfgxxWefZJHIm0=";
  };
in
stdenv.mkDerivation rec {
  pname = "pd-vstplugin";
  version = "0.6.2";

  src = fetchFromGitLab {
    domain = "git.iem.at";
    owner = "pd";
    repo = "vstplugin";
    tag = "v${version}";
    hash = "sha256-REp+x7mKzKrf+CW1mRQxYHHDN7MAxazc1RwC2AEyDJI=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libX11 ];

  # The build expects the SDKs laid out as `<dir>/pluginterfaces/...`.
  preConfigure = ''
    mkdir -p "$NIX_BUILD_TOP/vst2sdk/pluginterfaces" "$NIX_BUILD_TOP/vst3sdk"
    ln -s ${fst}/fst "$NIX_BUILD_TOP/vst2sdk/pluginterfaces/vst2.x"
    ln -s ${vst3-pluginterfaces} "$NIX_BUILD_TOP/vst3sdk/pluginterfaces"
    cmakeFlagsArray+=(
      "-DVST2DIR=$NIX_BUILD_TOP/vst2sdk"
      "-DVST3DIR=$NIX_BUILD_TOP/vst3sdk"
    )
  '';

  cmakeFlags = [
    (lib.cmakeBool "PD" true)
    (lib.cmakeBool "SC" false)
    (lib.cmakeBool "TESTSUITE" false)
    # Running Windows plugins requires the separately-built Wine host.
    (lib.cmakeBool "WINE" false)
    (lib.cmakeFeature "PD_INCLUDEDIR" "${puredata}/include/pd")
    (lib.cmakeFeature "PD_INSTALLDIR" "${placeholder "out"}")
  ];

  meta = {
    description = "Pd external to load VST2 and VST3 plugins";
    homepage = "https://git.iem.at/pd/vstplugin";
    changelog = "https://git.iem.at/pd/vstplugin/-/releases/v${version}";
    # vstplugin itself is BSD-3; the FST headers are GPL-3+ and the VST3 interfaces are MIT.
    license = with lib.licenses; [
      bsd3
      gpl3Plus
      mit
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ kugland ];
  };
}
