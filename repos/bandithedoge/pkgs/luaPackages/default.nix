{
  pkgs,
  sources,
}: rec {
  lua-dbus_proxy = pkgs.luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-dbus_proxy) src pname version;

    propagatedBuildInputs = with pkgs.luaPackages; [lgi];
    knownRockspec = src + "/rockspec/dbus_proxy-devel-1.rockspec";
  };

  lua-dbus = pkgs.luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-dbus) src pname version;

    propagatedBuildInputs = with pkgs.luaPackages; [ldbus];
    knownRockspec = src + "/${pname}-scm-0.rockspec";
  };
}
