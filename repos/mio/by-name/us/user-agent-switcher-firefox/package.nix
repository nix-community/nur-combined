{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  zip,
  writeShellApplication,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "user-agent-switcher-firefox";
  version = "1.4.114";

  extid = "user-agent-switcher@ninetailed.ninja";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "ntninja";
    repo = "user-agent-switcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CFuKq94+bU7AV4enr7Frl+q3eH4A0n3Semp7ZTd2Rf0=";
  };

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    pushd . > /dev/null
    zip -qr "$TMPDIR/user-agent-switcher.xpi" \
      manifest.json \
      _locales \
      assets \
      background \
      content \
      deps \
      ui \
      utils
    popd > /dev/null

    install -Dm644 "$TMPDIR/user-agent-switcher.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/user-agent-switcher.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
    updateScript = writeShellApplication {
      name = "update-user-agent-switcher-firefox";
      text = ''
        export UPDATE_NIX_ATTR_PATH="user-agent-switcher-firefox"
        exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
      '';
    };
  };

  meta = {
    description = "User-Agent Switcher Firefox add-on built from source";
    homepage = "https://gitlab.com/ntninja/user-agent-switcher";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
