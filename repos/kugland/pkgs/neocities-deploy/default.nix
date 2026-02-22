{ pkgs
, lib
, fetchFromGitHub
, rustPlatform
, buildRustPackage ? rustPlatform.buildRustPackage
,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.22";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-4JmHW1R5QAkAqx+kO0tdTBzwqmx5Tpg04XZr+iREUgk=";
  };
  cargoHash = "sha256-mIb7F+GtUh+DgET7wP4C03VDr8ExmbytXCBWu8ERkeo=";
  doCheck = false;
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = with lib.maintainers; [ kugland ];
  };
}
