{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  meson,
  ninja,
  pandoc,
  python3,
  versionCheckHook,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "run0edit";
  version = "0.7.1";
  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "HastD";
    repo = "run0edit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RZdueYT1c3rNQyNCP7RyldOwDQdnd+8I8LCQOq41nik=";
  };

  postPatch = ''
    oldChecksum=$(b2sum -l 256 run0edit_inner.py | cut -d' ' -f1)

    substituteInPlace run0edit_main.py \
      --replace-fail 'path="/usr/bin:/bin:/usr/sbin:/sbin"' \
        'path="/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"' \
      --replace-fail 'python_cmd = find_command("python3")' \
        'python_cmd = "${python3.interpreter}"'

    # Default PATH of the unprivileged editor, unless /etc/login.defs sets ENV_PATH
    substituteInPlace run0edit_inner.py \
      --replace-fail 'env["PATH"] = "/usr/local/bin:/bin:/usr/bin"' \
        'env["PATH"] = "/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/bin:/bin:/usr/bin"'

    newChecksum=$(b2sum -l 256 run0edit_inner.py | cut -d' ' -f1)
    substituteInPlace run0edit_main.py \
      --replace-fail "INNER_SCRIPT_B2: Final[str] = \"$oldChecksum\"" \
        "INNER_SCRIPT_B2: Final[str] = \"$newChecksum\""

    # install the example config to $out/etc
    substituteInPlace data/meson.build \
      --replace-fail "install_dir: sysconfdir /" "install_dir: get_option('prefix') / 'etc' /"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pandoc
  ];

  buildInputs = [
    python3
  ];

  mesonFlags = [
    (lib.mesonOption "sysconfdir" "/etc")
    (lib.mesonEnable "unit-tests" false)
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Allow a permitted user to edit a file as root using run0";
    homepage = "https://github.com/HastD/run0edit";
    changelog = "https://github.com/HastD/run0edit/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    platforms = lib.platforms.linux;
    mainProgram = "run0edit";
  };
})
