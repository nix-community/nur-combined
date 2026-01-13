{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  stdenv,
  perl,
  apple-sdk,
  zlib,
}:
rustPlatform.buildRustPackage rec {
  pname = "distant";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "chipsenkbeil";
    repo = "distant";
    rev = "v${version}";
    sha256 = "DcnleJUAeYg3GSLZljC3gO9ihiFz04dzT/ddMnypr48=";
  };

  nativeBuildInputs = [
    openssl
    stdenv.cc
    perl
    rustPlatform.bindgenHook
  ];

  buildInputs =
    [
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.isDarwin [ apple-sdk ];

  cargoHash = "sha256-HEyPfkusgk8JEYAzIS8Zj5EU0MK4wt4amlsJqBEG/Kc=";

  doCheck = false;

  meta = with lib; {
    description = "Library and tooling that supports remote filesystem and process operations.";
    homepage = "https://github.com/chipsenkbeil/distant";
    license = licenses.asl20;
  };
}
