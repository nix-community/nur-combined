{ lib, fetchFromGitHub, buildGoModule, ... }:

buildGoModule {
  pname = "devcontainer-cli-unofficial";
  version = "0.1.5524099953";

  vendorHash = "sha256-mp8ahX5vGgVBUKGTHsYovuLUi94RNNBdbWledMAmWls=";

  src = fetchFromGitHub {
    owner = "MartinLoeper";
    repo = "devcontainer-cli";
    rev = "62272d70131e7f400e3cb442c8ed304b8a53bab3";
    hash = "sha256-9ngkafjds8ALLyzKMkG1KgWD5ApwK0l1Paj5wlpU2Ts=";
  };

  meta = with lib; {
    homepage = "https://github.com/stuartleeks/devcontainer-cli";
    description = "Unofficial CLI for making it easier to work with Visual Studio Code dev containers from the terminal";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "devcontainerx";
  };
}
