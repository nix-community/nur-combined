{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "pmtiles";
  version = "0.0.1-alpha";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "PMTiles";
    rev = "v${version}";
    hash = "sha256-RxAEnQge/2xaIMH0dIQiTYP6kOPTM0QtfSNwE9hpkao=";
  };

  sourceRoot = "${src.name}/python";

  meta = with lib; {
    description = "Library and utilities to write and read PMTiles files - cloud-optimized archives of map tiles";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
