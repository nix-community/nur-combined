{ pkgs
, lib
, fetchFromGitHub
, rustPlatform
, buildRustPackage ? rustPlatform.buildRustPackage
,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.15";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-PkjgHXvFhTJ0AVRz6/hXkzo94tsIzgxHKuGNy3fDzIU=";
  };
  cargoHash = "sha256-DPp48x8ufPho1+zZkj9KeHhaaZ2zF6XS4E4JIfc2uJg=";
  doCheck = false;
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = with lib.maintainers; [ kugland ];
  };
}
