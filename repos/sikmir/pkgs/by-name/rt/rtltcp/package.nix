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
  version = "0.1.1-unstable-2025-01-11";

  src = fetchFromGitHub {
    owner = "niclashoyer";
    repo = "rtltcp";
    rev = "1a9ae7f59fd1d6eac13a445a8661bc67a9457da6";
    hash = "sha256-HbO4vlv2KkJNap+gTS9Pw8QbObBfiYc4nWDNRXwgvmA=";
  };

  cargoHash = "sha256-ZFAE+W911GpDFocO2Z3h4GksnJIVbSPsMuawbHhKtdI=";

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
