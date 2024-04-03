{ pkgs, lib, fetchFromGitea }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "todoit";
  version = "0.1.2";

  src = fetchFromGitea {
    domain = "git.ixhby.dev";
    owner = "ixhbinphoenix";
    repo = "todoit";
    rev = version;
    hash = "sha256-0hWKespkIeyLopGjgxhPh8SlGc0hWddNUFHS/PyYcrs=";
  };

  cargoHash = "sha256-4jWt8kd57/SSaT3QiobjHBuyQB+Md9HUu0b8woI7XB8=";

  meta = with lib; {
    description = "CLI Tool for showing all TODO's in a project";
    homepage = "https://git.ixhby.dev/ixhbinphoenix/todoit";
    license = licenses.gpl3Only;
  };
}
