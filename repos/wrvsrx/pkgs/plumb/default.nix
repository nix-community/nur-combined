{
  fetchFromGitHub,
  lib,
  nodejs,
  rustPlatform,
  stdenvNoCC,
  tree-sitter,
}:

let
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "plumb";
    tag = version;
    hash = "sha256-4bea8ukseluNRRK29eoi9VYYU6ZMWojqstr0lMdOouU=";
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

  cargoHash = "sha256-tKNFJtywHZm5ElurK1y0i1vKOMUHem4JVvS8K+u+k+s=";

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
