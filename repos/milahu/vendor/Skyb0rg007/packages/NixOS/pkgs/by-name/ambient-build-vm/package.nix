{
  lib,
  python3,
  stdenv,
  fetchFromRadicle,
  installShellFiles,
  versionCheckHook,
  testers,
}:
let
  python = python3.withPackages (ps: [ ps.pyaml ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ambient-build-vm";
  version = "0.1.0-unstable-2026-07-10";

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "z24yNhQC3JAyE3nbj8PP9SGUk5SgU";
    rev = "de6fa5addf8591fdbc36c15338e4b4c5ee4be78a";
    hash = "sha256-oFH+87CnxnkAqkUHYRGPe+nyqQVCkPON3+qgLzZmDWo=";
  };

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [ python ];
  nativeBuildInputs = [ installShellFiles ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  preVersionCheck = "version=\${version%%-*}";

  # TODO: Substitute vmdb2 and qemu-img
  installPhase = ''
    mkdir -pv \
      $out/share/doc/ambient-build-vm $out/share/ambient-build-vm

    substituteInPlace ambient-build-vm \
      --replace-fail "/usr/share" "$out/share"

    installBin ambient-build-vm
    install -D --mode=644 \
      --target-directory="$out/share/doc/ambient-build-vm" \
      README.md
    install -D --mode=644 \
      --target-directory="$out/share/ambient-build-vm" \
      ambient.service base.vmdb playbook.yml
  '';

  meta = {
    description = "Build VM images for Ambient CI";
    longDescription = ''
      ambient-build-vm creates a virtual machine image for use with
      Ambient, the CI system.
    '';
    mainProgram = "ambient-build-vm";
    homepage = "https://ambient.liw.fi/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
