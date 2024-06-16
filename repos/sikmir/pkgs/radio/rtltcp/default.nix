{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  rtl-sdr,
  systemd,
}:

rustPlatform.buildRustPackage rec {
  pname = "rtltcp";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "niclashoyer";
    repo = "rtltcp";
    rev = version;
    hash = "sha256-mGBU4O4RMTZPoxfg1zr2WeiZsfnIba6VHYX3FYTY+OY=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-d8MMWldc5pp6gY9KT57gkvmx6anG+eaIrHcmXIk7ocw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    rtl-sdr
    systemd
  ];

  meta = {
    description = "A rust implementation of rtl-tcp";
    homepage = "https://github.com/niclashoyer/rtltcp";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
