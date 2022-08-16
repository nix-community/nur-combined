{
  pkgs,
  sources,
}: rec {
  lua-dbus_proxy = pkgs.luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-dbus_proxy) src pname version;
    propagatedBuildInputs = with pkgs.luaPackages; [lgi];
    knownRockspec = src + "/rockspec/dbus_proxy-devel-1.rockspec";
  };
}
