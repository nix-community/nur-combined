{
  fetchFromRadicle,
  installShellFiles,
  lib,
  libisoburn,
  qemu,
  rustPlatform,
  stdenv,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ambient-ci";
  version = "0.17.0";

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "zwPaQSTBX8hktn22F6tHAZSFH2Fh"; # ambient-ci
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    tag = "v${finalAttrs.version}";
    hash = "sha256-UXRJ4pVrC5K8HoP3Xr6g56uf0S/8dVjZsYbu8JRjn9Y=";
  };

  cargoHash = "sha256-sShiiCumcigxn02VtfbaH+jI4nKhAR7F6FW0cWEdX1s=";

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ libisoburn ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  patchPhase = ''
    runHook prePatch

    substituteInPlace build.rs \
      --replace-fail 'VERSION={}@{hash}' 'VERSION={}'

    substituteInPlace src/config.rs \
      --replace-fail /usr/bin/kvm "${lib.getExe' qemu "qemu-kvm"}" \
      --replace-fail "executor: None" "executor: Some(TildePathBuf::new(\"$out/bin/ambient-execute-plan\".into()))"

    runHook postPatch
  '';

  postInstall = ''
    installManPage *.1
  '';

  passthru.updateScript = [ ./update.sh ];

  meta = {
    description = "Ambient continuous integration engine";
    longDescription = ''
      Ambient CI is a continuous integration system that aims to make it safe
      and secure to run CI on other people's code.
      It runs all the code from the project under test in a virtual machine
      that has no network access.
    '';
    mainProgram = "ambient";
    homepage = "https://ambient.liw.fi/";
    downloadPage = "https://radicle.network/nodes/${finalAttrs.src.seed}/rad%3A${finalAttrs.src.repo}";
    changelog = "${finalAttrs.meta.downloadPage}/remotes/${finalAttrs.src.node}/tree/${finalAttrs.src.tag}/NEWS.md";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
