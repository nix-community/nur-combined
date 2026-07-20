{
  fetchFromGitHub,
  lib,
  nodejs,
  rustPlatform,
  stdenvNoCC,
  tree-sitter,
}:

let
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "plumb";
    tag = version;
    hash = "sha256-HWm3Njh0t/4mJ0oQk5eVRbvFbRvvFbT+4jV8HIvRo7I=";
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

  cargoHash = "sha256-As75AEP2xiQGVAu5Tp7zBMVx+cjHSJFlzn+agoCnNZk=";

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
