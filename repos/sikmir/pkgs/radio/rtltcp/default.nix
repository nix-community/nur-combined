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

  meta = with lib; {
    description = "A rust implementation of rtl-tcp";
    inherit (src.meta) homepage;
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
