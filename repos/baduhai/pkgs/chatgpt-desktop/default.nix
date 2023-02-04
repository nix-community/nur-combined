{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "chatgpt-dekstop";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "lencx";
    repo = "ChatGPT";
    rev = "v${version}";
    hash = "sha256-SreFcpvNnqCGkcNQ1LEngk87G1fa5rNCQARNd0uS3vs=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tauri-plugin-autostart-0.1.0" = "sha256-ygOIIe5E/5mbi1vwmZBC1qxOAlES9zDhwjF//D4fFSA=";
    };
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "ChatGPT Desktop Application (Mac, Windows and Linux)";
    homepage = "https://github.com/lencx/ChatGPT";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
