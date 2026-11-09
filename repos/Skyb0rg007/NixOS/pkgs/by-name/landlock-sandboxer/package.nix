{
  lib,
  linuxPackages_7_3,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "landlock-sandboxer";
  inherit (linuxPackages_7_3.kernel) src version;

  sourceRoot = "linux-${finalAttrs.version}/samples/landlock";

  buildFlags = [
    "sandboxer"
    "CPPFLAGS=-I../../include/uapi"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 sandboxer $out/bin/landlock-sandboxer

    runHook postInstall
  '';

  passthru.updateScript = null;

  meta = {
    description = "Simple Landlock sandbox manager";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/samples/landlock";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "landlock-sandboxer";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
