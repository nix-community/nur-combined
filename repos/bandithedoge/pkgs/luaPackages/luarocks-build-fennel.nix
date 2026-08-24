{
  fetchFromSourcehut,
  lib,
  luaPackages,
  nix-update-script,
}:
luaPackages.buildLuarocksPackage {
  pname = "luarocks-build-fennel";
  version = "0.1.1-unstable-2024-03-18";
  src = fetchFromSourcehut {
    owner = "~xerool";
    repo = "luarocks-build-fennel";
    rev = "87992f7081097a7de03f9cdbbd2e40326851f563";
    hash = "sha256-w5UNq/sMXt2VJP5wae879Tuvo+FWh0ErLJcSMhFDOGI=";
  };

  knownRockspec = "rockspecs/luarocks-build-fennel-scm-1.rockspec";

  propagatedBuildInputs = with luaPackages; [
    fennel
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Teach LuaRocks how to build your Fennel rock";
    homepage = "https://sr.ht/~xerool/luarocks-build-fennel/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
