{ lib, buildGo125Module, fetchFromGitHub }:
let
  version = "0.1.0";
in
buildGo125Module {
  pname = "notizen";
  inherit version;

  src = fetchFromGitHub {
    owner = "peacock0803sz";
    repo = "notizen";
    tag = "v${version}";
    hash = "sha256-Ocz+m5LZRzhHOBJ3bkjlkHDbQQZZfYfCP0sWx+QPvaE=";
  };

  vendorHash = "sha256-n58Qmiv3gik1qkuXQFbQ+soeOQtUz1dUocEAJepqp/E=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/peacock0803sz/notizen/cmd/notizen/main.version=v${version}"
  ];
  doCheck = false;

  meta = {
    description = "A simple note-taking CLI";
    homepage = "https://github.com/peacock0803sz/notizen";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "notizen";
  };
}
