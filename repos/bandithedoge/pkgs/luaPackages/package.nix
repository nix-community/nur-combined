{
  sources,

  cairo,
  gobject-introspection,
  lib,
  luaPackages,
  pkg-config,
}:
{
  lua-dbus_proxy = luaPackages.buildLuarocksPackage {
    inherit (sources.lua-dbus_proxy) src pname;
    version = sources.lua-dbus_proxy.date;

    propagatedBuildInputs = with luaPackages; [ lgi ];
    knownRockspec = "rockspec/dbus_proxy-devel-1.rockspec";

    postPatch = ''
      substituteInPlace rockspec/dbus_proxy-devel-1.rockspec \
        --replace-fail "lgi >= 0.9.0, < 1" "lgi >= 0.9.0"
    '';

    meta = {
      description = "Simple API around GLib's GIO:GDBusProxy built on top of lgi";
      homepage = "https://stefano-m.github.io/lua-dbus_proxy/";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };

  lua-dbus = luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-dbus) src pname;
    version = sources.lua-dbus.date;

    knownRockspec = src + "/${pname}-scm-0.rockspec";

    propagatedBuildInputs = with luaPackages; [ ldbus ];

    meta = {
      description = "convenient dbus api in lua";
      homepage = "https://github.com/dodo/lua-dbus";
      license = lib.licenses.mit;
      broken = true;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };

  bling = luaPackages.buildLuarocksPackage rec {
    inherit (sources.bling) src pname;
    version = sources.bling.date;

    knownRockspec = "${pname}-dev-1.rockspec";

    preConfigure = "mv ${pname}-dev-2.rockspec ${pname}-dev-1.rockspec";

    meta = {
      description = "Utilities for the awesome window manager";
      homepage = "https://blingcorp.github.io/bling/";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };

  astal-lua = luaPackages.buildLuarocksPackage rec {
    inherit (sources.astal-lua) pname src;
    version = sources.astal-lua.date;

    knownRockspec = src + "/astal-*.rockspec";

    propagatedBuildInputs = with luaPackages; [
      argparse
      lgi
    ];

    passthru._ignoreDupe = true;

    meta = {
      description = "Lua bindings for libastal";
      homepage = "https://github.com/tokyob0t/astal-lua";
      license = lib.licenses.lgpl21Plus;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };

  luarocks-build-fennel = luaPackages.buildLuarocksPackage rec {
    inherit (sources.luarocks-build-fennel) pname src;
    version = sources.luarocks-build-fennel.date;

    knownRockspec = "${src}/rockspecs/${pname}-scm-1.rockspec";

    propagatedBuildInputs = with luaPackages; [
      fennel
    ];

    meta = {
      description = "Teach LuaRocks how to build your Fennel rock";
      homepage = "https://sr.ht/~xerool/luarocks-build-fennel/";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };

  lgi = luaPackages.buildLuarocksPackage rec {
    inherit (sources.lgi) pname src;
    version = sources.lgi.date;

    knownRockspec = "${src}/lgi-scm-1.rockspec";

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      cairo
      gobject-introspection
    ];

    passthru._ignoreDupe = true;

    meta = {
      description = "Dynamic Lua binding to GObject libraries using GObject-Introspection";
      homepage = "https://github.com/lgi-devs/lgi";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };

  lua-resty-mpd = luaPackages.buildLuarocksPackage rec {
    inherit (sources.lua-resty-mpd) pname version src;

    knownRockspec = "${src}/specs/lua-resty-mpd-${version}-0.rockspec";

    meta = {
      description = "Client library for the Music Player Daemon, compatible with OpenResty, cqueues, and Luasocket";
      homepage = "https://buffering.party/software/lua-resty-mpd/";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.bandithedoge ];
    };
  };
}
