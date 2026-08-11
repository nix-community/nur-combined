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
  version = "0.16.0";

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "zwPaQSTBX8hktn22F6tHAZSFH2Fh"; # ambient-ci
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    tag = "v${finalAttrs.version}";
    hash = "sha256-F8keawBsAC2Xynv00J93qPzaJV+qgW13l0uakZHX5ck=";
  };

  cargoHash = "sha256-ApbVjZnt+cWSgnJ1dNjIVd+UkgWT1GiMJWQhi+6aAqA=";

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
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
