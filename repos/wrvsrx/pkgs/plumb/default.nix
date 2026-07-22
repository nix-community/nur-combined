{
  fetchFromGitHub,
  lib,
  nodejs,
  rustPlatform,
  stdenvNoCC,
  tree-sitter,
}:

let
  version = "0.10.1";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "plumb";
    tag = version;
    hash = "sha256-dbGagaziaqIWe9VPm16dHotkMCVuAKzThDH6wDvYPOk=";
  };

  generatedSource = stdenvNoCC.mkDerivation {
    pname = "tree-sitter-plumb-src";
    inherit version;
    src = src + "/tree-sitter-plumb";

    nativeBuildInputs = [
      nodejs
      tree-sitter
    ];

    buildPhase = ''
      runHook preBuild
      tree-sitter generate
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r . "$out"
      runHook postInstall
    '';
  };

  tree-sitter-plumb = tree-sitter.buildGrammar {
    language = "plumb";
    inherit version;
    src = generatedSource;

    passthru.generatedSource = generatedSource;

    meta = {
      description = "Tree-sitter grammar for plumb";
      homepage = "https://github.com/wrvsrx/plumb/tree/${version}/tree-sitter-plumb";
      license = lib.licenses.mit;
    };
  };
in
rustPlatform.buildRustPackage {
  pname = "plumb";
  inherit version src;

  cargoHash = "sha256-LN6p383mSjzPjyERGOCoBaa2qWbC8KmojaFo+18UnOo=";

  postInstall = ''
    mkdir -p $out/share/plumb
    cp -r skills $out/share/plumb/
  '';

  passthru = {
    inherit tree-sitter-plumb;
  };

  meta = {
    description = "Strict plumb markup language and tooling";
    homepage = "https://github.com/wrvsrx/plumb";
    license = lib.licenses.mit;
    mainProgram = "plumb-ls";
  };
}
