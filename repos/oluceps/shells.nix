{ inputs, _pkgs }:
let system = "x86_64-linux"; pkgs = _pkgs.${system}; in

# { inherit (inputs.eunomia-bpf.devShells.${system}) eunomia-dev ebpf-dev; }
  #   //
{

  kernel =
    (pkgs.buildFHSUserEnv {
      name = "kernel-build-env";
      targetPkgs = pkgs: (with pkgs;
        [
          pkgconfig
          pkg-config
          ncurses
          qt5.qtbase
          # pkgsCross.mipsel-linux-gnu.stdenv.cc
          # pkgsCross.ppc64.stdenv.cc
          pkgsCross.aarch64-multiplatform.stdenv.cc
          # python2
          bison
          flex
          openssl.dev
          pahole
          bear
        ]
        ++ pkgs.linux.nativeBuildInputs);
      runScript = pkgs.writeScript "init.sh" ''
        # export ARCH=powerpc
        # export CROSS_COMPILE=powerpc64-unknown-linux-gnuabielfv2-
        export ARCH=arm64
        export CROSS_COMPILE=aarch64-linux-android-
        export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.qt5.qtbase.dev}/lib/pkgconfig"
        export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
        export QT_QPA_PLATFORMTHEME=qt5ct
        exec bash
      '';
    }).env;
}
