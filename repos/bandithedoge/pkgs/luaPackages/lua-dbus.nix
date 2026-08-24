{
  fetchFromGitHub,
  lib,
  luaPackages,
  nix-update-script,
}:
luaPackages.buildLuarocksPackage {
  pname = "lua-dbus";
  version = "scm-0-unstable-2015-04-22";
  src = fetchFromGitHub {
    owner = "dodo";
    repo = "lua-dbus";
    rev = "cdef26d09aa61d7f1f175675040383f6ae0becbb";
    hash = "sha256-S+W6QTqv4kdyR86GCyDLnkml10dO4ZVNXEd3/7vDFGE=";
  };

  knownRockspec = "lua-dbus-scm-0.rockspec";

  propagatedBuildInputs = with luaPackages; [ ldbus ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "convenient dbus api in lua";
    homepage = "https://github.com/dodo/lua-dbus";
    license = lib.licenses.mit;
    broken = true;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
