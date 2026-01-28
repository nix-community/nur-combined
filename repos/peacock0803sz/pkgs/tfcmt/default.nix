{ lib, buildGo125Module, fetchFromGitHub }:
let
  version = "4.14.12";
in
buildGo125Module {
  pname = "tfcmt";
  inherit version;

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "tfcmt";
    tag = "v${version}";
    hash = "sha256-S7zH8TxRRzRjLG9b3ixeCsOdMwNU10W6jFoqILPuGPs=";
  };

  vendorHash = "sha256-f/dKs9MkhSrWrmbmJLDMUDDwgrwWMs1q0WKnfHVioyU=";
  ldflags = [ "-s" "-w" "-X=main.version=v${version}" ];

  meta = {
    description = "tfcmt enhances mercari/tfnotify in many ways, including Terraform >= v0.15 support and advanced formatting options";
    homepage = "https://suzuki-shunsuke.github.io/tfcmt/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "tfcmt";
  };
}
