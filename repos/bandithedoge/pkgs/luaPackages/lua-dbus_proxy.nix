{
  fetchFromGitHub,
  lib,
  luaPackages,
  nix-update-script,
}:
luaPackages.buildLuarocksPackage {
  pname = "lua-dbus_proxy";
  version = "0.10.4-unstable-2025-11-15";
  src = fetchFromGitHub {
    owner = "stefano-m";
    repo = "lua-dbus_proxy";
    rev = "0f84913358c1f7ce939b79f071bea9883a75cfb5";
    hash = "sha256-H44JBe2n4QZcQRyQTcYY/DtuG7XQgolPrdPgUU6SJTs=";
  };

  propagatedBuildInputs = [ (luaPackages.callPackage ./lgi.nix { }) ];
  knownRockspec = "rockspec/dbus_proxy-devel-1.rockspec";

  postPatch = ''
    substituteInPlace rockspec/dbus_proxy-devel-1.rockspec \
      --replace-fail "lgi >= 0.9.0, < 1" "lgi >= 0.9.0"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Simple API around GLib's GIO:GDBusProxy built on top of lgi";
    homepage = "https://stefano-m.github.io/lua-dbus_proxy/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
