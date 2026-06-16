{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "comqtt";
  version = "2.6.4";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "wind-c";
    repo = "comqtt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VdqvnQvn8zucKjaDdU3kXUauBySIi9Y4dy+i64PAF2Y=";
  };

  vendorHash = "sha256-dK5o3BOskSAb1FU1rndzJTlJJF5l76tBjwPqysh8GwI=";

  subPackages = [
    "cmd/single"
  ];

  postInstall = ''
    mv $out/bin/{single,comqtt}
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
