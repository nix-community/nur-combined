{ stdenv, gtk3, luajit, lua51Packages, webkitgtk, pkgconfig, sqlite, fetchFromGitHub, glib_networking, gsettings_desktop_schemas, makeWrapper }:

let
  lualibs       = with lua51Packages; [ luafilesystem luasqlite3 ];
  getPath       = lib : type : "${lib}/lib/lua/${luajit.luaversion}/?.${type};${lib}/share/lua/${luajit.luaversion}/?.${type}";
  getLuaPath    = lib : getPath lib "lua";
  getLuaCPath   = lib : getPath lib "so";
  luaPath       = stdenv.lib.concatStringsSep ";" (map getLuaPath lualibs);
  luaCPath      = stdenv.lib.concatStringsSep ";" (map getLuaCPath lualibs);
in

stdenv.mkDerivation {

  name = "luakit-2018.01.05";

  src = fetchFromGitHub {
    owner = "luakit";
    repo = "luakit";
    rev = "5f3555244a56526cb36dd31d25bffefc8589294d";
    sha256 = "1z66s18jzlw2gp8ih3mijr76fwa3wlk8sfg1xsmj6v4fbzqnr1z3";
  };

  buildInputs = [ gtk3 luajit webkitgtk pkgconfig sqlite makeWrapper ];

  postPatch = ''
    sed -i -e "s|/etc/xdg/luakit/|$out/etc/xdg/luakit/|" lib/lousy/util.lua
    patchShebangs ./build-utils
  '';

  buildPhase = ''
    make DEVELOPMENT_PATHS=0 USE_LUAJIT=1 INSTALLDIR=$out DESTDIR=$out PREFIX=$out MANPREFIX=$out/share/man DOCDIR=$out/share/luakit/doc PIXMAPDIR=$out/share/pixmaps APPDIR=$out/share/applications LIBDIR=$out/lib/luakit USE_GTK3=1 LUA_PATH='?/init.lua;?.lua;${luaPath}' LUA_CPATH='${luaCPath}'
    cat buildopts.h
  '';

  installPhase = let luaKitPath = "$out/share/luakit/lib/?/init.lua;$out/share/luakit/lib/?.lua"; in
    ''
      make DEVELOPMENT_PATHS=0 INSTALLDIR=$out DESTDIR=$out PREFIX=$out USE_GTK3=1 install
      wrapProgram $out/bin/luakit                                         \
        --prefix GIO_EXTRA_MODULES : "${glib_networking.out}/lib/gio/modules" \
        --prefix XDG_DATA_DIRS : "${gsettings_desktop_schemas}/share:$out/usr/share/:$out/share/:$GSETTINGS_SCHEMAS_PATH"     \
        --prefix XDG_CONFIG_DIRS : "$out/etc/xdg"                         \
        --set LUA_PATH '${luaKitPath};${luaPath};'                      \
        --set LUA_CPATH '${luaCPath};'
    '';

  meta = with stdenv.lib; {
    description = "Fast, small, webkit based browser framework extensible in Lua";
    homepage    = http://luakit.org;
    license     = licenses.gpl3;
  };
}
