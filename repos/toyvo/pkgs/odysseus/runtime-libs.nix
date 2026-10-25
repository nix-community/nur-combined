# Shared C/C++ libs that pip-installed native wheels (onnxruntime / fastembed)
# dlopen at runtime. Used by the NixOS / nix-darwin Odysseus service modules
# to populate LD_LIBRARY_PATH for the app and ChromaDB services.
pkgs: with pkgs; [
  stdenv.cc.cc.lib # libstdc++.so.6, libgomp.so.1 (onnxruntime / fastembed)
  zlib
  openssl
  libffi
  bzip2
  xz
  sqlite
  ncurses
  readline
]
