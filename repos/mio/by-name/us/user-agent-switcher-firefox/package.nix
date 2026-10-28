{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "user-agent-switcher-firefox";
  version = "1.4.112";

  extid = "user-agent-switcher@ninetailed.ninja";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "ntninja";
    repo = "user-agent-switcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-U5q5p1wBhviAZgza9RH+QoYpBtv82VhjFR7c756LopE=";
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
  };

  meta = {
    description = "User-Agent Switcher Firefox add-on built from source";
    homepage = "https://gitlab.com/ntninja/user-agent-switcher";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
