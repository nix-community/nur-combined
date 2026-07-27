{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "tdf";
  version = "2024-08-16";

  src = fetchFromGitHub {
    owner = "itsjunetime";
    repo = "tdf";
    rev = "4296c92d7d91b210149ecfb8dd72e487fb747eff";
    sha256 = "sha256-mExvglPK31uNm6eqXPUBrTRk6VbGW0k0sE7ncDESX1k=";
  };

  # cargoHash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
       "ratatui-0.28.0" = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
       "ratatui-image-1.0.5ratatui-0.28.0" = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
     };
  };
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Transfer files over LAN from your mobile device to your computer.";
    homepage = "https://github.com/SCOTT-HAMILTON/qrup";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
