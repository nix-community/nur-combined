{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

buildGoModule rec {
    pname = "surge";
    version = "0.5.5";

    src = fetchFromGitHub {
        owner = "surge-downloader";
        repo = "surge";
        tag = "refs/tags/v0.5.5";
        hash = "sha256-IpDPJYPDeUHxgtbqgUCgdTg+h98H3xhn5gN4T+D0YjU=";
    };

    vendorHash = "sha256-IGVt/HanZHglYSZ8WASrzqvTZZtK/bJpJzXNVqSqUfE=";

    preCheck = ''
        export HOME=$(mktemp -d)
    '';

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
