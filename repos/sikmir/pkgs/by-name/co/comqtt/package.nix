{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "comqtt";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "wind-c";
    repo = "comqtt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aknPBbe9bSp33s58SBg/SFhLK1VOuCwOmnHBwCPfwWU=";
  };

  vendorHash = "sha256-dK5o3BOskSAb1FU1rndzJTlJJF5l76tBjwPqysh8GwI=";

  subPackages = [
    "cmd/single"
    "cmd/cluster"
  ];

  postInstall = ''
    mv $out/bin/{single,comqtt}
    mv $out/bin/{cluster,comqtt-cluster}
  '';

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "A lightweight, high-performance go mqtt server";
    homepage = "https://github.com/wind-c/comqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "comqtt";
  };
})
