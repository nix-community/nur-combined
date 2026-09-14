{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nodejs_26,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "downdoc";
  version = "1.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "opendevise";
    repo = "downdoc";
    tag = "v${finalAttrs.version}-stable";
    hash = "sha256-CEpj7+tpGxNn6uY5BttgbjDkpKI6XoIjJQrsVBTICyk=";
  };

  buildInputs = [
    nodejs_26
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp package.json $out
    cp -r lib $out/
    cp -r bin $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rapidly converts AsciiDoc to Markdown";
    homepage = "https://github.com/opendevise/downdoc";
    changelog = "https://github.com/opendevise/downdoc/blob/${finalAttrs.src.rev}/CHANGELOG.adoc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "downdoc";
    platforms = lib.platforms.all;
  };
})
