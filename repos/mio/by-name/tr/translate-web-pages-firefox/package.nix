{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "translate-web-pages-firefox";
  version = "10.2.5.0";

  extid = "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}";

  src = fetchFromGitHub {
    owner = "FilipePS";
    repo = "Traduzir-paginas-Web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xjYRB4qFNZ0EorRQtysTZybYGppulfMrKAYbdznlGWg=";
  };

  npmDepsHash = "sha256-7u8pzIoRGTkhe1KhvtmlHabXGXS+L/g5NKKS337PEPA=";

  nativeBuildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild
    npx gulp firefox-build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    xpi=$(find build -name 'TWP_*_Firefox.zip' -print -quit)
    test -n "$xpi"

    install -Dm644 "$xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/translate-web-pages.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/FilipePS/Traduzir-paginas-Web/releases/tag/v${finalAttrs.version}";
    description = "TWP – Translate Web Pages Firefox add-on built from source";
    homepage = "https://github.com/FilipePS/Traduzir-paginas-Web";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
