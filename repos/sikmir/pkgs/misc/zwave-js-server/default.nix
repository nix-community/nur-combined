{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodePackages,
}:

buildNpmPackage rec {
  pname = "zwave-js-server";
  version = "1.36.0";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = "zwave-js-server";
    rev = version;
    hash = "sha256-+GyQy7CVd3t98kUDTpPzmPs5WNU8Ct/e+kHPh08gb0Q=";
  };

  npmDepsHash = "sha256-u9Y9yOLZZ+DnFYAAhF0SUa+qW+Mj+3duzAKKS6xCkp0=";

  nativeBuildInputs = [ nodePackages.ts-node ];

  meta = {
    description = "Full access to zwave-js driver through Websockets";
    homepage = "https://zwave-js.github.io/zwave-js-server";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
