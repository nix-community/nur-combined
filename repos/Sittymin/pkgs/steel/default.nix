{ lib
, rustPlatform
, fetchFromGitHub
, fullInstall ? true
}:

rustPlatform.buildRustPackage {
  pname = "steel";
  version = "unstable";
  src = fetchFromGitHub ({
    owner = "mattwparas";
    repo = "steel";
    rev = "d1a20050ba30158d3f1272f4d57aefeea8ca7644";
    sha256 = "sha256-HA9ZRVJ7T4s0hdEoKVU3y3mctIhE4u2N0nKT/IGBENo=";
  });

  cargoHash = "sha256-fYon6jfijtO6yAXpjkTirsH/HbH+PoWx/pJcywCBjto=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildPhase = ''
    export STEEL_HOME=$out/.steel
    export CARGO_HOME=$out/cargo
    ${lib.optionalString fullInstall ''
        cargo xtask install --path .
    ''}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r $CARGO_HOME/bin/* $out/bin/
  '';

  meta = with lib; {
    description = "An embedded scheme interpreter in Rust";
    homepage = "https://github.com/mattwparas/steel";
    license = with licenses; [ asl20 mit ];
    platforms = platforms.linux;
  };
}
