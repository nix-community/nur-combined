{
  fetchFromGitHub,
  lib,
  luaPackages,
  nix-update-script,

  cairo,
  gobject-introspection,
  pkg-config,
}:
luaPackages.buildLuarocksPackage {
  pname = "lgi";
  version = "0.9.2-unstable-2026-07-28";
  src = fetchFromGitHub {
    owner = "lgi-devs";
    repo = "lgi";
    rev = "7a2276f9657a50ee548a636f2e646f96ec748bbd";
    hash = "sha256-YObCJg5RAW5TbZDo1e7NxdDqYaGbk8p5sbAzX7Y0lVg=";
  };

  knownRockspec = "lgi-scm-1.rockspec";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    gobject-introspection
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
    description = "Dynamic Lua binding to GObject libraries using GObject-Introspection";
    homepage = "https://github.com/lgi-devs/lgi";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
