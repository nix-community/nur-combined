{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "revshell";
  version = "0.8.9";

  src = fetchFromGitHub {
    owner = "Gubarz";
    repo = "revshell";
    rev = "v${version}";
    hash = "sha256-rCj8CT3VOsocvF1CVlimhuAsxsB91axp7oBUxxinZF4=";
  };

  vendorHash = "sha256-yC6O/+yvC0U8cms0sxfLNNb2/Q6MpACAltf7J7L1HWM=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Gubarz/revshell/cmd.version=${version}"
  ];

  meta = {
    description = "CLI reverse shell generator";
    homepage = "https://github.com/Gubarz/revshell";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.unix;
    maintainers = [];
    mainProgram = "revshell";
  };
}
