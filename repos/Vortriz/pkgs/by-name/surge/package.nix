{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

buildGoModule rec {
    pname = "surge";
    version = "0.8.6";

    src = fetchFromGitHub {
        owner = "surge-downloader";
        repo = "surge";
        tag = "v0.8.6";
        hash = "sha256-o0GtuzqhCv39PRHeH1VXq4NLDgJoAQagIMlAkljY/Is=";
    };

    vendorHash = "sha256-tXJUr/URQZC+tNq+HOIuinaqbeElJMPWQH/MG1rY80I=";

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
