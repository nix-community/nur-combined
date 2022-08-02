{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.luakit) pname version src;

  nativeBuildInputs = with pkgs; [
    pkgconfig
  ];

  buildInputs = with pkgs;
    [
      glib-networking
      gtk3
      (luajit.withPackages (ps: with ps; [luafilesystem]))
      sqlite
      webkitgtk
    ]
    ++ (with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

  makeFlags = [
    "PREFIX=${builtins.placeholder "out"}"
    "XDGPREFIX=${builtins.placeholder "out"}/etc/xdg"
  ];

  preBuild = ''
    export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua"
  '';

  inherit (pkgs.luakit) meta;
}
