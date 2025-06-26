{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "comqtt";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "wind-c";
    repo = "comqtt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FUdOzJ2COMrzU4C/xYblrUsW0SzYhESG68DF8Dg1KMM=";
  };

  vendorHash = "sha256-aw9sdkDaa2Z1ZrJ38RxilRRnMMMnWRzBrNIq58ia7zE=";

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
