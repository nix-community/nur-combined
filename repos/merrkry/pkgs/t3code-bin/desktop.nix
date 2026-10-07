{
  lib,
  git,
  gh,
  mkT3code,
  unwrapped,
  providerPackages,
  commandLineArgs,
}:

mkT3code {
  pname = "t3code-desktop-bin";
  inherit unwrapped providerPackages;
  runtimePackages = [
    git
    gh
  ]
  ++ providerPackages;
  passthru = { };

  # The upstream URL handler uses APPIMAGE as its launch target.
  extraWrapperArgs = ''
    --set APPIMAGE "$out/bin/t3code-desktop" \
    --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true}}" \
    --add-flags ${lib.escapeShellArg commandLineArgs}
  '';
  extraInstallCommands = ''
    ln -s ${unwrapped}/share "$out/share"
  '';
}
