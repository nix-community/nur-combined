{
  fetchFromGitHub,
  buildGoModule,
  lib,
}:
buildGoModule rec {
  name = "mihomo-meta";
  version = "d4ececae20eda1f61f0ee87021756c81b54e4251";

  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "mihomo";
    rev = "${version}";

    hash = "sha256-VnzoJTugf/OUyA2HzCc506rQvPjwT7aK2Wx2fiQ9los=";
  };

  vendorHash = "sha256-bcaNTPtoCkvmPvvj50rE3539+ux3LcLbrR9CVBysL6I=";

  # Do not build testing suit
  excludedPackages = ["./test"];

  CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/metacubex/mihomo/constant.Version=${lib.substring 0 8 version}"
  ];

  tags = [
    "with_gvisor"
  ];

  # Network required
  doCheck = false;

  postInstall = ''
    mv $out/bin/mihomo $out/bin/mihomo-meta
  '';

  meta = with lib; {
    description = "A rule-based tunnel in Go";
    homepage = "https://github.com/MetaCubeX/mihomo/tree/Alpha";
    license = licenses.gpl3Only;
    maintainers = ["lcx12901"];
  };
}
