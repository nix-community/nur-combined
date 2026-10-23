{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "beefetch";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "mirdukkkkk";
    repo = "beefetch";
    tag = finalAttrs.version;
    hash = "sha256-h1HAZMm8izcQPt0JgOKQTlkOcMEUV8IVJggJXd9OoOQ=";
  };

  vendorHash = null;

  subPackages = [ "cmd/beefetch" ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Neofetch clone written in Go with the ability to display 🐝";
    homepage = "https://github.com/mirdukkkkk/beefetch";
    license = lib.licenses.gpl3Only;
    mainProgram = "beefetch";
    platforms = lib.platforms.unix;
  };
})
