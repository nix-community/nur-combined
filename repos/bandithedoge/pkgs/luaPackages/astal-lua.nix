{
  fetchFromGitHub,
  lib,
  lua52Packages,
  nix-update-script,
}:
lua52Packages.buildLuarocksPackage {
  pname = "astal-lua";
  version = "0-unstable-2026-08-14";
  src = fetchFromGitHub {
    owner = "tokyob0t";
    repo = "astal-lua";
    rev = "740b6833cec80b6c4081bf8c84b7279d76c02852";
    hash = "sha256-S+301HV05n5ENyPiFzogudy7Yz30mZI0G3tvykiKXNk=";
  };

  rockspecVersion = "*";

  propagatedBuildInputs = with lua52Packages; [
    argparse
    (callPackage ./lgi.nix { lua55Packages = lua52Packages; })
  ];

  passthru = {
    _ignoreDupe = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };

  meta = {
    description = "Lua bindings for libastal";
    homepage = "https://github.com/tokyob0t/astal-lua";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
