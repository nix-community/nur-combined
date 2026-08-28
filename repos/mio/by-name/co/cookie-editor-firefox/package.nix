{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "cookie-editor-firefox";
  version = "1.13.0";

  extid = "{c3c10168-4186-445c-9c5b-63f12b8e2c87}";

  src = fetchFromGitHub {
    owner = "Moustachauve";
    repo = "cookie-editor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/q7pQ3Kn6Bn0pjh/n5YooT26N6Jg/iGe4OVf86xYRMY=";
  };

  npmDepsHash = "sha256-JGY9ZXOmRIN7bzHtTM8JT/h1OSYVZLpyfg4abyKID5w=";

  nativeBuildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild
    npx grunt --force json-replace clean:firefox copy:firefox replace:firefox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd build/firefox > /dev/null
    zip -qr "$TMPDIR/cookie-editor.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/cookie-editor.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/cookie-editor.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/Moustachauve/cookie-editor/releases/tag/v${finalAttrs.version}";
    description = "Cookie-Editor Firefox add-on built from source";
    homepage = "https://cookie-editor.com";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
