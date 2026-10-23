{
  lib,
  rustPlatform,
  fetchFromCodeberg,
  runCommand,
  installShellFiles,
  mdbook,
}:

# Fork of helix (codeberg.org/hsctech/helix) adding Bloblang support.
# Expression mirrors nixpkgs' helix-unwrapped, pinned to the fork:
# buildRustPackage reads cargoHash outside the fixpoint, so overriding
# nixpkgs' helix-unwrapped cannot change it.
rustPlatform.buildRustPackage (
  finalAttrs:
  let
    defaultRuntimeDir = runCommand "helix-default-runtime" { } ''
      cp -r --no-preserve=mode ${finalAttrs.src}/runtime $out
      rm -rf $out/grammars $out/queries
    '';
  in
  {
    pname = "helix-unwrapped";
    version = "25.07.1-unstable-2026-10-16";

    outputs = [
      "out"
      "doc"
    ];

    src = fetchFromCodeberg {
      owner = "hsctech";
      repo = "helix";
      rev = "1f26d2c09615b0d71e0423ad39e3298c2bf9f5ee";
      hash = "sha256-NevKFeyabuXIDXTiBUEhiMJbaB6mYFIW1rWyztFR+a8=";
    };

    cargoHash = "sha256-kJP6LMcx5z91XzO4PNbNvSSWOjVvJW35O7Z4uW9J+m8=";

    postPatch = ''
      # mdbook 0.5 uses asset hashing for CSS/JS files
      # Remove custom theme to use default mdbook theme with correct asset references
      rm -f book/theme/index.hbs
    '';

    nativeBuildInputs = [
      installShellFiles
      mdbook
    ];

    env = {
      # disable fetching and building of tree-sitter grammars in the helix-term build.rs
      HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";
      HELIX_DEFAULT_RUNTIME = defaultRuntimeDir;
    };

    postBuild = ''
      mdbook build book -d ../book-html
    '';

    postInstall = ''
      installShellCompletion contrib/completion/hx.{bash,fish,zsh}
      mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
      cp contrib/Helix.desktop $out/share/applications/Helix.desktop
      cp contrib/helix.png $out/share/icons/hicolor/256x256/apps/helix.png
      mkdir -p $doc/share/doc
      cp -r ../book-html $doc/share/doc/$name
    '';

    # hx reports its own version (25.07.x), not the package version.
    doInstallCheck = false;

    meta = {
      description = "Post-modern modal text editor (hsctech fork with Bloblang support)";
      homepage = "https://codeberg.org/hsctech/helix";
      changelog = "https://codeberg.org/hsctech/helix/src/branch/master/CHANGELOG.md";
      license = lib.licenses.mpl20;
      mainProgram = "hx";
      maintainers = [
        {
          name = "hsctech";
          email = "henrik@hsctech.eu";
        }
      ];
    };
  }
)
