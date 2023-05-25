{ roundcubePlugin, fetchzip, nix-update-script }:

roundcubePlugin rec {
  pname = "carddav";
  version = "5.0.1";

  src = fetchzip {
    url = "https://github.com/mstilkerich/rcmcarddav/releases/download/v${version}/carddav-v${version}.tar.gz";
    hash = "sha256-qB4cif4lK9IejOqPexp5RmcGrNGcB1h6cxcGFYhZvRA=";
  };

  passthru.updateScript = nix-update-script { };
}
