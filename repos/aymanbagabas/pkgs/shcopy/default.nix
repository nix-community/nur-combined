{ buildGoModule, fetchFromGitHub, lib, ... }:

buildGoModule rec {
  pname = "shcopy";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "aymanbagabas";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-lEYMBBtBGAJjU0F1HgvuH0inW6S5E9DyKxwQ6A9tdM4=";
  };

  vendorHash = "sha256-kD73EozkeUd23pwuy71bcNmth2lEKom0CUPDUNPNB1Q=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.ProjectName=${pname}"
    "-X=main.Version=${version}"
    "-X=main.CommitSHA=${src.rev}"
    "-X=main.builtBy=nixpkgs"
  ];

  meta = with lib; {
    description = "Copy text to your system clipboard locally and remotely using ANSI OSC52 sequence";
    homepage = "https://github.com/aymanbagabas/shcopy";
    license = licenses.mit;
  };
}
