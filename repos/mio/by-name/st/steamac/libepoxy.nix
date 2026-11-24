{
  lib,
  stdenv,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  python3,
}:

# libepoxy is built from pinned sources before virglrenderer and libkrun, as
# upstream's host/libepoxy/build.sh does.
stdenv.mkDerivation (finalAttrs: {
  pname = "libepoxy";
  version = "1.5.10";

  src = fetchurl {
    url = "https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz";
    hash = "sha256-ByzaS1ndCYu6jCNjpiRymdsfqJQR3CIci4G47oGS5iM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  # Upstream builds with MACOSX_DEPLOYMENT_TARGET=15.0 (the launcher's minimum).
  env.MACOSX_DEPLOYMENT_TARGET = "15.0";

  # gen_dispatch.py's /usr/bin/env shebang is not executable in the sandbox.
  postPatch = ''
    patchShebangs src/gen_dispatch.py
  '';

  # The two CGL tests need a WindowServer/GPU connection, which the Nix build
  # sandbox does not provide (they SIGSEGV there). The other tests still run.
  doCheck = false;

  postInstall = ''
    install_name_tool -id @rpath/libepoxy.0.dylib "$out/lib/libepoxy.0.dylib"
  '';

  meta = {
    description = "Library for handling OpenGL function pointer management (Steamac build)";
    homepage = "https://github.com/anholt/libepoxy";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
})
