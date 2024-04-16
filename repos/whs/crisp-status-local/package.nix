{
  lib, stdenv, pkgs, rustPlatform
}:
let
  version = "1.3.7";
  sha256 = "sha256-PphEZQ/WmA9f89K+oKhnX9nyDp/havSn/ndAo5iQgqg=";
in rustPlatform.buildRustPackage {
  pname = "crisp-status-local";
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "crisp-im";
    repo = "crisp-status-local";
    rev = "v${version}";
    inherit sha256;
  };
  
  cargoHash = "sha256-LC0E/aCsGMDbtEgGQm9JYdi0MGbffzaWicOQf61HoYs=";
  
  meta = {
    description = "Monitor internal hosts and report their status to Crisp Status";
    homepage = "https://github.com/crisp-im/crisp-status-local";
    license = lib.licenses.mpl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
