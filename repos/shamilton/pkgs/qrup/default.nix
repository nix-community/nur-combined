{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "qrup";
  version = "2022-06-17";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "qrup";
    rev = "8c4fd1e7057f7d9d11ad814942f6090c59c267bd";
    sha256 = "sha256-DQWJ+sHO3BWEr/3JzUpfcIPVwUP44erARPqHMJMlp1k=";
  };

  cargoHash = "sha256-IKrCBPBgBm8MrMo/PvURontRUNK/Tef18gS9gKoT7bQ=";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Transfer files over LAN from your mobile device to your computer.";
    homepage = "https://github.com/SCOTT-HAMILTON/qrup";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
