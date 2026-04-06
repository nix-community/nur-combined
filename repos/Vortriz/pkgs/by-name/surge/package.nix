{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

buildGoModule rec {
    pname = "surge";
    version = "0.7.8";

    src = fetchFromGitHub {
        owner = "surge-downloader";
        repo = "surge";
        tag = "v0.7.8";
        hash = "sha256-32Cjg2dfTAlRBUlbnkdvzMzla9jwIYOe+0mrPlhHDVg=";
    };

    vendorHash = "sha256-pbKnMrfY/abu/Mj0HhDhTUSOlWl82kgIM0zXwtlQw/U=";

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
