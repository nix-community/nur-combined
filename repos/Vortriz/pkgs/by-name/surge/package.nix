{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

buildGoModule rec {
    pname = "surge";
    version = "0.7.0";

    src = fetchFromGitHub {
        owner = "surge-downloader";
        repo = "surge";
        tag = "v0.7.0";
        hash = "sha256-0rgD9tMt3P/Bme39WleIdQQFOzU1RlG8H43bVNjkC50=";
    };

    vendorHash = "sha256-XIXH/d4Fjk3KFFQn+MfRGiAgR48KGvWoh1PuNb3yryg=";

    doCheck = false;

    ldflags = [
        "-s"
        "-w"
        "-X=github.com/surge-downloader/surge/cmd.Version=${version}"
        "-X=github.com/surge-downloader/surge/cmd.BuildTime=1970-01-01T00:00:00Z"
    ];

    meta = {
        description = "Surge is a blazing fast, open-source terminal (TUI) download manager built in Go";
        homepage = "https://github.com/surge-downloader/surge";
        license = lib.licenses.mit;
        mainProgram = "surge";
    };
}
