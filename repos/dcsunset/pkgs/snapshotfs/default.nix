{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "snapshotfs";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yA6wPpi3lxEVXN+S/NW3AXOD6Gs5wn/XPS2zRwK6+ug=";
  };

  cargoHash = "sha256-+GBCl+WcCx+fWzw7zwIUcLW0raRv4a5nqpZgAQ92cnc=";

  meta = with lib; {
    description = "A fuse-based read-only filesystem to provide a snapshot view (tar archives) of directories or files without actually creating the archives";
    homepage = "https://github.com/DCsunset/snapshotfs";
    license = licenses.agpl3;
  };
}
