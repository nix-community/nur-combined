{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "esa";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "esa";
    rev = "v${version}";
    hash = "sha256-u3XuOwaxg29ecJo7+vyzl2Z3Jx2XnLGvxC+mE7S81n4=";
  };

  vendorHash = "sha256-qoFxm5sNHBOnm10kZsbnMVf+R5BpvjivqHpHTCvFVXA=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Fastest way to create personalized AI agents";
    homepage = "https://github.com/meain/esa";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "esa";
  };
}
