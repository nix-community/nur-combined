{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-staticmaps";
  version = "2021-12-31";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "go-staticmaps";
    rev = "56e3560e444bd7855f8de837dd491cb0a4bd5ae9";
    hash = "sha256-r1PQ45hLy/akquN1vhuhCu+71E8ptjT1boCXupbH8lw=";
  };

  patches = [ ./extra-tileproviders.patch ];

  vendorHash = "sha256-VwdQsm7VghVtX2O41jNxILTuiLff4rTfXP41+IzUmMs=";

  meta = with lib; {
    description = "A go (golang) library and command line tool to render static map images using OpenStreetMap tiles";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
