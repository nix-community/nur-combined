{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "fabric";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "danielmiessler";
    repo = "fabric";
    rev = version;
    hash = "sha256-ejq3ISn+bv4L46l7qRg80TdxwbKMbD+WQQwOGsovQt0=";
  };

  vendorHash = "sha256-V7P5vtc1ahPHYH5vc72v1z1uLQN6Y1Ft7zabZ9U7F9c=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Fabric is an open-source framework for augmenting humans using AI. It provides a modular framework for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere";
    homepage = "https://github.com/danielmiessler/fabric";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "fabric";
  };
}
