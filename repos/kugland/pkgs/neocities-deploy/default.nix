{ pkgs
, lib
, fetchFromGitHub
, rustPlatform
, buildRustPackage ? rustPlatform.buildRustPackage
,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.18";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-aMwr+mEdlN1QvSbTm6j6M2G/EFeWzP6WuMcFWjNXC18=";
  };
  cargoHash = "sha256-yJQ4gHROU7kr7w0bsCzeWI2giHDkyrEFIwcWX8uhvlQ=";
  doCheck = false;
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = with lib.maintainers; [ kugland ];
  };
}
