{
  lib,
  callPackage,
  callPackages,
  stdenvNoCC,
  makeShellWrapper,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  chatgpt-unwrapped ? callPackage ./unwrapped.nix { },
  commandLineArgs ? "",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "chatgpt";
  inherit (finalAttrs.passthru.unwrapped) version;

  strictDeps = true;
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeShellWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    makeShellWrapper ${lib.getExe chatgpt-unwrapped} "$out/bin/chatgpt" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs}
    ln -s ${chatgpt-unwrapped}/share "$out/share"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = chatgpt-unwrapped.passthru // {
    unwrapped = chatgpt-unwrapped;
    tests = callPackages ./tests.nix { chatgpt = finalAttrs.finalPackage; };
  };

  inherit (chatgpt-unwrapped) meta;
})
