{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  rtl-sdr,
  systemd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rtltcp";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "niclashoyer";
    repo = "rtltcp";
    tag = finalAttrs.version;
    hash = "sha256-mGBU4O4RMTZPoxfg1zr2WeiZsfnIba6VHYX3FYTY+OY=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-Zvf/cglQ4SmeMru9rMYBSkbT0Rx91vLrLOO0VCwHcwk=";

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
})
