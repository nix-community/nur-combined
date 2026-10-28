{
  lib,
  stdenvNoCC,
  fetchurl,
  patchelf,
  glibc,
  gtk3,
  gdk-pixbuf,
  glib,
  fontconfig,
  libX11,
  wayland,
  webkitgtk_4_1,
  libsoup_3,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.1794";

  src = fetchurl {
    url = "https://github.com/yetone/magpie-releases/releases/download/v${finalAttrs.version}/magpie-linux-amd64";
    hash = "sha256-wYPAQ0SUX9oZmcOkTPVre9zw4mS91nClTtUZnQPBPd0=";
  };

  dontUnpack = true;

  # Libraries the prebuilt binary directly NEEDs (GTK/WebKit stack plus
  # wayland-client); they become the RUNPATH below.
  runtimeLibs = [
    gtk3
    gdk-pixbuf
    glib
    fontconfig
    libX11
    wayland
    webkitgtk_4_1
    libsoup_3
  ];

  nativeBuildInputs = [ patchelf ];
  buildInputs = finalAttrs.runtimeLibs;

  # autoPatchelfHook is deliberately not used: it always rewrites PT_INTERP
  # before DT_RUNPATH, and patchelf >= 0.19 corrupts this binary in that order
  # (the rewritten file has a PHDR segment that no PT_LOAD covers, so ld.so
  # segfaults on startup). Patching the RUNPATH first and the interpreter last
  # yields a working binary with both patchelf 0.15 and 0.19.
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/magpie
    patchelf --set-rpath "${lib.makeLibraryPath finalAttrs.runtimeLibs}" $out/bin/magpie
    patchelf --set-interpreter "${lib.getLib glibc}/lib/ld-linux-x86-64.so.2" $out/bin/magpie
    runHook postInstall
  '';

  # Catch ELF breakage (e.g. from a future patchelf regression) at build time:
  # a corrupted interpreter/RUNPATH makes the binary die before main().
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/magpie --version | grep -qx 'magpie ${finalAttrs.version}'
    runHook postInstallCheck
  '';

  meta = {
    description = "One local gateway serving every AI agent's model";
    homepage = "https://usemagpie.ai";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "magpie";
  };
})
