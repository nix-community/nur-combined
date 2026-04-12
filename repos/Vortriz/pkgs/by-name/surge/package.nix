{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

buildGoModule rec {
    pname = "surge";
    version = "0.8.0";

    src = fetchFromGitHub {
        owner = "surge-downloader";
        repo = "surge";
        tag = "v0.8.0";
        hash = "sha256-M6XlKd9JFVg7/01M5l7fjsi7HrcL+Smo+fQrhFRI7B0=";
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
