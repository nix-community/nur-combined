{ lib
, fetchFromGitHub
, buildRustPackage
, pkg-config
, openssl
}:

buildRustPackage rec {
  pname = "chunkdrive";
  version = "2023-08-12";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "chunkdrive";
    rev = "7d8683699c899123b4d9838b59fa2adc63377a83";
    sha256 = "sha256-kLuNaMBwf2+n1VD+9WhINGuZNxpFRiWubhz42ezNy18=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-zcfjzvWGLWMwz/fE3HIgjUtrMew9ZTPa59m69S3893Q=";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Check if tables and items in a .toml file are lexically sorted";
    homepage = "https://github.com/devinr528/cargo-sort-ck";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
