{ lib
, buildGoModule
, fetchFromGitHub,
}:

buildGoModule rec {
    pname = "drivedlgo";
    version = "1.6.8";

    src = fetchFromGitHub {
        owner = "JaskaranSM";
        repo = "drivedlgo";
        rev = version;
        hash = "sha256-Vn6xWdFa+S2Pl+j0EEI0oxgZBECGZkHerd5HATip2bg=";
    };

    vendorHash = "sha256-Hhi/iXq6Ka+iLVx8B1h0Wbz2hfECGelbqXL09s2UNpc=";

    ldflags = [ "-s" "-w" ];

    meta = with lib; {
        description = "A Minimal Google Drive Downloader Written in Go";
        homepage = "https://godoc.org/github.com/JaskaranSM/drivedlgo";
        changelog = "https://github.com/JaskaranSM/drivedlgo/releases/tag/${version}";
        license = licenses.mit;
        mainProgram = "drivedlgo";
    };
}

