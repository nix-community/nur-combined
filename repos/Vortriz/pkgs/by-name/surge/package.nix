{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

buildGoModule rec {
    pname = "surge";
    version = "0.8.3";

    src = fetchFromGitHub {
        owner = "surge-downloader";
        repo = "surge";
        tag = "v0.8.3";
        hash = "sha256-uHCsisVe2O5hZ8W2kXmVd7IQ5QQZLKCx5EtywslSlI4=";
    };

    vendorHash = "sha256-aOgs3wbTqYdknT/aiV1KeBRGMREz2segvTy5I+z6jgE=";

    doCheck = false;

    ldflags = [
        "-s"
        "-w"
        "-X=github.com/surge-downloader/surge/cmd.Version=${version}"
        "-X=github.com/surge-downloader/surge/cmd.BuildTime=1970-01-01T00:00:00Z"
    ];

    postInstall = ''
        mv $out/bin/Surge $out/bin/surge
    '';

    meta = {
        description = "Surge is a blazing fast, open-source terminal (TUI) download manager built in Go";
        homepage = "https://github.com/surge-downloader/surge";
        license = lib.licenses.mit;
        mainProgram = "surge";
    };
}
