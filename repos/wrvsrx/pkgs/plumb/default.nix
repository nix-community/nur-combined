{
  fetchFromGitHub,
  lib,
  nodejs,
  pandoc,
  rustPlatform,
  stdenvNoCC,
  tree-sitter,
  vimUtils,
}:

let
  version = "0.24.0";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "plumb";
    tag = version;
    hash = "sha256-jPyc0ELPbVine7NSvo586hYfhLIjKmqTZN1Q/Z8k3+E=";
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

  neovim-plugin = vimUtils.buildVimPlugin {
    pname = "plumb.nvim";
    inherit version;
    src = src + "/contrib/nvim";
  };
in
rustPlatform.buildRustPackage {
  pname = "plumb";
  inherit version src;

  cargoHash = "sha256-KnDJFwO4AArWn6jJ0gNrgAutW+jjufGx/0d2VSNtZT0=";

  nativeCheckInputs = [ pandoc ];

  preCheck = ''
    export PLUMB_CACHE_DIR="$TMPDIR/plumb-cache"
  '';

  postInstall = ''
    mkdir -p $out/share/plumb
    cp -r skills $out/share/plumb/
  '';

  passthru = {
    inherit neovim-plugin tree-sitter-plumb;
  };

  meta = {
    description = "Strict plumb markup language and tooling";
    homepage = "https://github.com/wrvsrx/plumb";
    license = lib.licenses.mit;
    mainProgram = "plumb";
  };
}
