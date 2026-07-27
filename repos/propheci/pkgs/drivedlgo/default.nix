{ lib
, buildGoModule
, fetchFromGitHub
, nix-filter
}:

buildGoModule rec {
  pname = "drivedlgo";
  version = "1.6.8";

  src = nix-filter {
    name = "drivedlgo";
    root = fetchFromGitHub {
      owner = "JaskaranSM";
      repo = "drivedlgo";
      rev = version;
      hash = "sha256-Vn6xWdFa+S2Pl+j0EEI0oxgZBECGZkHerd5HATip2bg=";
    };
    exclude = [
      "README.md"
      "LICENSE"
      ".gitignore"
      ".goreleaser.yml"
      ".github"
    ];
  };

  vendorHash = "sha256-Hhi/iXq6Ka+iLVx8B1h0Wbz2hfECGelbqXL09s2UNpc=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A Minimal Google Drive Downloader Written in Go";
    homepage = "https://github.com/JaskaranSM/drivedlgo";
    changelog = "https://github.com/JaskaranSM/drivedlgo/releases/tag/${version}";
    license = licenses.mit;
    mainProgram = "drivedlgo";
  };
}

