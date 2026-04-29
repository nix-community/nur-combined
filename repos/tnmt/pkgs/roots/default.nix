{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "roots";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "roots";
    rev = "v${version}";
    hash = "sha256-ACMRfWY/lhc3C/KVhuUyS1rgkSHGWPxZrmYt+pXupJI=";
  };

  vendorHash = "sha256-uxcT5VzlTCxxnx09p13mot0wVbbas/otoHdg7QSDt4E=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/k1LoW/roots/version.Version=${version}"
  ];

  meta = {
    description = "Tool for exploring multiple root directories, such as those in a monorepo project";
    homepage = "https://github.com/k1LoW/roots";
    license = lib.licenses.mit;
    mainProgram = "roots";
  };
}
