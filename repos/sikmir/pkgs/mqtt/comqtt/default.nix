{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "comqtt";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "wind-c";
    repo = "comqtt";
    tag = "v${version}";
    hash = "sha256-h8mHneZisky62axAkT0WwR89g76uIqoW+lit7siaJew=";
  };

  vendorHash = "sha256-PHwLKuFweQcGgnjq/L7bOTd0czYvw2YeVmlVFCafPMU=";

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
  };
}
