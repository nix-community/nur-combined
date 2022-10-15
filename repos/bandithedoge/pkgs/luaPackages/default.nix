{
  pkgs,
  sources,
}: rec {
  lua-dbus_proxy = pkgs.luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-dbus_proxy) src pname version;

    propagatedBuildInputs = with pkgs.luaPackages; [lgi];
    knownRockspec = src + "/rockspec/dbus_proxy-devel-1.rockspec";

    meta = with pkgs.lib; {
      description = "Simple API around GLib's GIO:GDBusProxy built on top of lgi";
      homepage = "https://stefano-m.github.io/lua-dbus_proxy/";
      license = licenses.asl20;
    };
  };

  lua-dbus = pkgs.luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-dbus) src pname;
    version = sources.lua-dbus.date;

    propagatedBuildInputs = with pkgs.luaPackages; [ldbus];
    knownRockspec = src + "/${pname}-scm-0.rockspec";

    meta = with pkgs.lib; {
      description = "convenient dbus api in lua";
      homepage = "https://github.com/dodo/lua-dbus";
      license = licenses.mit;
    };
  };

  bling = pkgs.luaPackages.buildLuarocksPackage rec {
    inherit (sources.bling) src pname;
    version = sources.bling.date;

    knownRockspec = src + "/${pname}-dev-1.rockspec";

    meta = with pkgs.lib; {
      description = "Utilities for the awesome window manager";
      homepage = "https://blingcorp.github.io/bling/";
      license = licenses.mit;
    };
  };
}
