{
  lib,
  stdenvNoCC,
  makeShellWrapper,
  pname,
  unwrapped,
  providerPackages,
  runtimePackages,
  extraWrapperArgs,
  extraInstallCommands,
  passthru,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  inherit pname;
  inherit (finalAttrs.passthru.unwrapped) version meta;

  strictDeps = true;
  dontUnpack = true;
  dontBuild = true;
  nativeBuildInputs = [ makeShellWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    makeShellWrapper ${lib.getExe finalAttrs.passthru.unwrapped} "$out/bin/${finalAttrs.meta.mainProgram}" \
      --prefix PATH : ${lib.escapeShellArg (lib.makeBinPath runtimePackages)} \
      --inherit-argv0 ${extraWrapperArgs}
    ${extraInstallCommands}

    runHook postInstall
  '';

  passthru =
    unwrapped.passthru
    // {
      inherit unwrapped providerPackages;
    }
    // passthru;
})
