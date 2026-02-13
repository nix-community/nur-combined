{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "qq-jfryy";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "JFryy";
    repo = "qq";
    rev = "v${version}";
    hash = "sha256-Ukk9PWlTKQ1S9LbGJtvrrKxXqYZDIdYkrs6f2vFJcZs=";
  };

  vendorHash = "sha256-dTC9Nk1zixv/9jG+xUGC7Yoc8FFlY7wio9FLoUQO7RA=";

  ldflags = ["-s" "-w"];

  meta = {
    description = "jq-compatible multi-format configuration transcoder";
    homepage = "https://github.com/JFryy/qq";
    license = lib.licenses.mit;
    mainProgram = "qq";
    platforms = lib.platforms.unix;
  };
}
