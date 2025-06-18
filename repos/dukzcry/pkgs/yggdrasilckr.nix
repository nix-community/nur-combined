{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests,
  yggdrasil
}:

buildGoModule rec {
  pname = "yggdrasilckr";
  version = "0.5.12";

  src = fetchFromGitHub {
    owner = "neilalexander";
    repo = "yggdrasilckr";
    rev = "v${version}";
    hash = "sha256-OKDVaU9mwq0HQcbML2SoHICHtJOHj4v0h9gQoF/q1Gw=";
  };

  vendorHash = "sha256-iWPzMK+773Lj6GQcUCH7eJnKFRv4QAM1YADW35Mam00=";

  subPackages = [
    "cmd/yggdrasilckr"
  ];

  ldflags = [
    "-X github.com/yggdrasil-network/yggdrasil-go/src/version.buildVersion=${version}"
    "-X github.com/yggdrasil-network/yggdrasil-go/src/version.buildName=yggdrasil"
    "-X github.com/yggdrasil-network/yggdrasil-go/src/config.defaultAdminListen=unix:///var/run/yggdrasil/yggdrasil.sock"
    "-s"
    "-w"
  ];

  passthru.tests.basic = nixosTests.yggdrasil;

  postInstall = ''
    ln -s ${lib.getExe' yggdrasil "genkeys"} $out/bin
    ln -s ${lib.getExe' yggdrasil "yggdrasilctl"} $out/bin
    mv $out/bin/yggdrasilckr $out/bin/yggdrasil
  '';

  meta = with lib; {
    description = "A special Yggdrasil build that re-adds tunnel routing/crypto-key routing (CKR) support";
    homepage = src.meta.homepage;
    license = licenses.lgpl3;
    maintainers = with maintainers; [];
  };
}
