{
  lib,
  python3,
  stdenv,
  fetchFromRadicle,
  installShellFiles,
  versionCheckHook,
  testers,
  nix-update-script,
}:
let
  python = python3.withPackages (ps: [ ps.pyaml ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ambient-build-vm";
  version = "0-unstable-2026-08-23";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "z24yNhQC3JAyE3nbj8PP9SGUk5SgU";
    rev = "897911e28c4112c7ce7d90c1939ae9568a2ef876";
    hash = "sha256-2JTIvBRnGms4P5JLTR36XDY2aI083PA0FtZRfIDfznI=";
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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Build VM images for Ambient CI";
    longDescription = ''
      ambient-build-vm creates a virtual machine image for use with
      Ambient, the CI system.
    '';
    mainProgram = "ambient-build-vm";
    homepage = "https://ambient.liw.fi/";
    downloadPage = "https://radicle.network/nodes/${finalAttrs.src.seed}/rad%3A${finalAttrs.src.repo}";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
