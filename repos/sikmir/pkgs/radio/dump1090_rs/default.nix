{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  soapysdr,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dump1090_rs";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "rsadsb";
    repo = "dump1090_rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YMi+DaLORiy36rl02sKoCanI1hQSh4eRKJdrruxvMWg=";
  };

  cargoHash = "sha256-d/v2BTPOYW6nJdDlrKektrXTwQUgaapKkwwaG+W3oFY=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ soapysdr ];

  meta = {
    description = "Multi-SDR supported Rust translation of the popular dump1090 project for ADS-B demodulation";
    homepage = "https://github.com/rsadsb/dump1090_rs";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = true; # Unable to find libclang
  };
})
