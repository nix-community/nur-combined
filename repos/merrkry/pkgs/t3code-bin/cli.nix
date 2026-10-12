{
  lib,
  stdenv,
  git,
  gh,
  alsa-lib,
  at-spi2-core,
  dbus,
  expat,
  glib,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  systemdLibs,
  mkT3code,
  unwrapped,
  providerPackages,
}:

mkT3code {
  pname = "t3code-bin";
  inherit unwrapped providerPackages;
  runtimePackages = [
    git
    gh
  ]
  ++ providerPackages;
  # T3 downloads its headless browser at runtime, outside autoPatchelfHook.
  # The browser and its ldd diagnostics inherit this library path.
  extraWrapperArgs = ''
    --prefix LD_LIBRARY_PATH : ${
      lib.escapeShellArg (
        lib.makeLibraryPath [
          alsa-lib
          at-spi2-core
          dbus
          expat
          glib
          libgbm
          libx11
          libxcb
          libxcomposite
          libxdamage
          libxext
          libxfixes
          libxkbcommon
          libxrandr
          nspr
          nss
          stdenv.cc.cc.lib
          systemdLibs
        ]
      )
    }
  '';
  extraInstallCommands = "";
  passthru = { };
}
