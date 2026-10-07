{
  stdenv,
  autoPatchelfHook,
  libx11,
  src,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  name = "chatgpt-cua-node";
  inherit src;

  strictDeps = true;
  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    libx11
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a "$src"/. "$out/"

    runHook postInstall
  '';

  preFixup = ''
    restoreLibvips() {
      # patchelf relocates libvips' .init without updating DT_INIT, causing a crash.
      # Node already loads its C++ runtime; retain libvips' upstream $ORIGIN RUNPATH.
      # https://github.com/NixOS/patchelf/issues/639
      local libvips=lib/node_modules/@img/sharp-libvips-linux-x64/lib
      cp -a "$src/$libvips"/libvips-cpp.so.* "$out/$libvips/"
    }
    postFixupHooks+=(restoreLibvips)
  '';
})
