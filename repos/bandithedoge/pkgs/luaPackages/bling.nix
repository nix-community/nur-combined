{
  fetchFromGitHub,
  lib,
  luaPackages,
  nix-update-script,
}:
luaPackages.buildLuarocksPackage {
  pname = "bling";
  version = "0-unstable-2024-12-18";
  src = fetchFromGitHub {
    owner = "blingcorp";
    repo = "bling";
    rev = "bcfb671248cf9ff636b7fd7d7120d8ed9deaa395";
    hash = "sha256-rhhUsXQ3awjFiEHEG0axilSCWS6pR+w74K/pIfEUc5w=";
  };

  knownRockspec = "bling-dev-1.rockspec";

  preConfigure = "mv bling-dev-2.rockspec bling-dev-1.rockspec";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Utilities for the awesome window manager";
    homepage = "https://blingcorp.github.io/bling/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
