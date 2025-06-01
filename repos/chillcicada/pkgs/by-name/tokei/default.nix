{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tokei";
  version = "13.0.0-alpha.8";

  src = fetchFromGitHub {
    owner = "XAMPPRocky";
    repo = "tokei";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-jCI9VM3y76RI65E5UGuAPuPkDRTMyi+ydx64JWHcGfE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-LzlyrKaRjUo6JnVLQnHidtI4OWa+GrhAc4D8RkL+nmQ=";

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
    darwin.apple_sdk.frameworks.Security
  ];

  checkInputs = lib.optionals stdenv.hostPlatform.isDarwin [ zlib ];

  # enable all output formats
  buildFeatures = [ "all" ];

  meta = {
    description = "Program that allows you to count your code, quickly";
    longDescription = ''
      Tokei is a program that displays statistics about your code. Tokei will show number of files, total lines within those files and code, comments, and blanks grouped by language.
    '';
    homepage = "https://github.com/XAMPPRocky/tokei";
    license = with lib.licenses; [
      asl20 # or
      mit
    ];
    mainProgram = "tokei";
  };
})
