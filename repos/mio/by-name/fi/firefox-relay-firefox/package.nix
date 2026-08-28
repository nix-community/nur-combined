{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "firefox-relay-firefox";
  version = "2.8.1";

  extid = "private-relay@firefox.com";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "fx-private-relay-add-on";
    rev = "04a9015b69b04cf766c4001d0161e237f49861c6";
    hash = "sha256-XcMcUYwaJAWHR5EI2EGuSScZdx6q9udowG9sHIKjOvw=";
    fetchSubmodules = true;
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-n4VmUjy5O/4W7H9C0WGEEJVUzBIExBnqEDonfPmlgLk=";

  nativeBuildInputs = [ nodejs_22 ];

  buildPhase = ''
    runHook preBuild
    bash ./config-domain.sh https://relay.firefox.com
    npx web-ext build -s src/ --overwrite-dest
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    artifact=$(find web-ext-artifacts -name 'firefox_relay-*' -print -quit)
    test -n "$artifact"

    install -Dm644 "$artifact" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/firefox-relay.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    description = "Firefox Relay Firefox add-on built from source";
    homepage = "https://github.com/mozilla/fx-private-relay-add-on";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
