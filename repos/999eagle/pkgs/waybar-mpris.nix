{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "waybar-mpris";
  version = "unstable-2022-01-31";

  src = fetchFromGitHub {
    owner = "arafatamim";
    repo = pname;
    rev = "a10ff4c12de19cb4d776cd990300bd16f0d570b4";
    sha256 = "0babh4bfnvg9gykrggyw7nabwydwqcc1d0w7p7w8zv5r3gq1ss5h";
  };
  vendorSha256 = "08yvs5gczpdlkxdkc77w68anf79m1yw7w3ggjyk21cwv6brkz93q";

  meta = with lib; {
    description = "MPRIS module for Waybar";
    homepage = "https://github.com/arafatamim/waybar-mpris";
    license = licenses.mit;
  };
}
