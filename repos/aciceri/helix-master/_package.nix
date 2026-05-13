# Stolen and adapted from https://github.com/helix-editor/helix/blob/master/default.nix
{
  rustPlatform,
  callPackage,
  runCommand,
  installShellFiles,
  git,
  fetchFromGitHub,
  helix,
  lib,
  writeShellScript,
  python3,
  nix-update,
  nurl,
}:
let
  helixSource = fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    rev = "8c41b11607924f7584b77c8a6e6b16439a2f559f";
    hash = "sha256-woJV7tJwwzjR0xWDNuGpwMENe/OEMAdSGg+nqWs9tUE=";
  };

  grammars = callPackage ./_grammars.nix { };

  runtimeDir = runCommand "helix-runtime" { } (
    ''
      mkdir -p $out
      ln -s ${helixSource}/runtime/* $out
      rm -r $out/grammars
      mkdir $out/grammars
    ''
    + lib.concatMapAttrsStringSep "\n" (name: grammar: ''
      ln -s ${grammar}/${name}.so $out/grammars/${name}.so
    '') (lib.filterAttrs (n: v: lib.isDerivation v) grammars)
  );
in
rustPlatform.buildRustPackage (self: {
  cargoHash = "sha256-xCfehdDSgDLJSKC+oDLts0J6lvKx0ZlXOwLRVdk5FzM=";

  propagatedBuildInputs = [ runtimeDir ];

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  buildType = "release";

  name = "helix-master";
  version = "master-${helixSource.rev}";
  pname = "helix-master";
  src = helixSource;

  HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";

  HELIX_NIX_BUILD_REV = helixSource.rev;

  doCheck = false;
  strictDeps = true;

  env.HELIX_DEFAULT_RUNTIME = runtimeDir;

  postInstall = ''
    mkdir -p $out/lib
    installShellCompletion ${helixSource}/contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/{256x256,scalable}/apps}
    cp ${helixSource}/contrib/Helix.desktop $out/share/applications/Helix.desktop
    cp ${helixSource}/logo.svg $out/share/icons/hicolor/scalable/apps/helix.svg
    cp ${helixSource}/contrib/helix.png $out/share/icons/hicolor/256x256/apps/helix.png
  '';

  meta = {
    inherit (helix.meta)
      description
      homepage
      license
      mainProgram
      ;
    maintainers = [ lib.maintainers.aciceri ];
  };

  passthru = {
    tree-sitter-grammars = grammars;
    inherit helixSource;
    updateScript = writeShellScript "update-script.sh" ''
      set -euo pipefail
      export PATH="${lib.makeBinPath [ nurl ]}:$PATH"

      echo "Updating helix-master source..."
      ${lib.getExe nix-update} --flake helix-master --version=branch

      echo "Fetching updated helixSource..."
      HELIX_SRC=$(nix eval .#helix-master.src.outPath --raw)

      echo "Generating grammars.json..."
      ${lib.getExe python3} ${./generate_grammars.py} \
        "$HELIX_SRC/languages.toml" \
        -o packages/helix-master/grammars.json \

      if [ $? -ne 0 ]; then
        echo "Error: Failed to generate grammars.json" >&2
        exit 1
      fi

      echo "Done! Updated grammars.json"
    '';
  };
})
