{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  libseccomp,
  python3,
  nix-update-script,
  withQtPrompter ? true,
}:
let
  prompterPython = python3.withPackages (ps: [
    ps.pyside6
    ps.pyyaml
  ]);
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "libturnstile";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "micromaomao";
    repo = "libturnstile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9OjN4KOhueoQ4+iotA9d3P17/B79dA7ryXfwrqN+dCQ=";
  };

  cargoHash = "sha256-WZrkv2Idga6LEUsyLoO+jrXX96oy3Hckcl3EY3BTG5s=";

  postPatch = ''
    substituteInPlace src/bin/sandbox-config-default.yaml \
      --replace-fail "  /lib: rx" "  /nix/store: rx" \
      --replace-fail "  /lib64: rx" "  /run/current-system: rx"
  ''
  + lib.optionalString withQtPrompter ''
    substituteInPlace prompter/main.py \
      --replace-fail "#!/usr/bin/env python3" "#!${lib.getExe prompterPython}"
  '';

  buildFeatures = [ "tools" ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libseccomp
    # For patchShebangs on allow_all.py
    python3
  ];

  checkFlags = [
    "--skip=sandbox::managed_bind_mount_sandbox::tests"
  ];

  postInstall = ''
    install -Dm755 prompter/allow_all.py $out/libexec/turnstile/allow_all.py
    install -Dm644 -t $out/share/turnstile/example-configs example-configs/*.yaml
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/fstrace --help > /dev/null
    $out/bin/turnstile-sandbox --help > /dev/null
    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Seccomp-unotify access tracer";
    longDescription = ''
      Turnstile implements a seccomp-unotify-based access tracer, and a
      namespace / bind-mount based sandbox that can be used with the tracer to
      dynamically find out about access requests and allow them.
    '';
    homepage = "https://github.com/micromaomao/libturnstile";
    license = lib.licenses.mit;
    mainProgram = "turnstile-sandbox";
    platforms = lib.platforms.linux;
  };
})
