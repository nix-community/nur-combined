{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "egemi";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "NfNitLoop";
    repo = "egemi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mx2ZLFsNPUsIjrsB+CGiLa3LRdbbBzNWCMr2pzC4wEY=";
  };

  cargoHash = "sha256-ouKVdE7wJ2jFM3oGo8wHZxpgZF6zj114mvuYPC2LBe8=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = {
    description = "An egui browser for Gemini Text";
    homepage = "https://github.com/NfNitLoop/egemi";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
