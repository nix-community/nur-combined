{
  lib,
  stdenv,
  racket,
  cacert,
  runCommand,
}:

let
  # FOD that raco-installs racket-langserver + transitive deps into a
  # staging PLTADDONDIR. `--no-setup` skips bytecode compilation so the
  # output is pure source — compiled .zo would bake /nix/store paths,
  # which a FOD's content is forbidden from referencing.
  addon = stdenv.mkDerivation {
    pname = "racket-langserver-addon";
    version = "1.0-unstable-2026-04-30";

    dontUnpack = true;
    nativeBuildInputs = [
      racket
      cacert
    ];

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR/home
      mkdir -p "$HOME"
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      export PLTADDONDIR=$TMPDIR/racket-addon
      mkdir -p "$PLTADDONDIR"
      export SOURCE_DATE_EPOCH=1

      raco pkg install --batch --auto --no-docs --no-setup --user racket-langserver

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      addonDirs=("$PLTADDONDIR"/*)
      if [[ "''${#addonDirs[@]}" -ne 1 || ! -d "''${addonDirs[0]}" ]]; then
        echo "Expected exactly one version directory in $PLTADDONDIR" >&2
        exit 1
      fi
      # PLTADDONDIR stores user packages below a Racket-version directory.
      # Strip that directory so the fixed-output source tree can be reused by
      # later compatible Racket releases; the normal derivation adds the
      # current version directory back before running raco setup.
      cp -r "''${addonDirs[0]}/." "$out/"
      # Drop any straggler compiled artifacts; FOD outputs cannot have
      # /nix/store references.
      find "$out" -type d -name compiled -exec rm -rf {} + 2>/dev/null || true
      find "$out" -type f \( -name '*.zo' -o -name '*.dep' \) -delete 2>/dev/null || true
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-HH/5HvKEgbh7pnnGSOdjJhN8h6UsxoFaYoLrhuzNSwM=";
  };
in
runCommand "racket-langserver"
  {
    pname = "racket-langserver";
    inherit (addon) version;
    nativeBuildInputs = [ racket ];

    meta = {
      description = "Language Server Protocol implementation for Racket";
      homepage = "https://github.com/jeapostrophe/racket-langserver";
      license = lib.licenses.mit;
      mainProgram = "racket-langserver";
      platforms = lib.platforms.unix;
    };
  }
  ''
    mkdir -p $out/bin $out/share

    # Copy (not symlink) so raco setup can write bytecode into the tree.
    addonDir="$(
      PLTADDONDIR=$out/share/racket \
        ${racket}/bin/racket \
        -e '(require setup/dirs)' \
        -e '(display (path-only (find-user-pkgs-dir)))'
    )"
    mkdir -p "$addonDir"
    cp -r --no-preserve=mode ${addon}/. "$addonDir/"
    chmod -R u+w $out/share/racket

    # Pre-compile bytecode; baking /nix/store refs is fine in a normal
    # derivation (only FODs are forbidden from doing so).
    PLTADDONDIR=$out/share/racket \
      ${racket}/bin/raco setup --no-docs --pkgs racket-langserver

    cat > $out/bin/racket-langserver <<EOF
    #!${stdenv.shell}
    export PLTADDONDIR="$out/share/racket"
    exec ${racket}/bin/racket -l racket-langserver -- "\$@"
    EOF
    chmod +x $out/bin/racket-langserver
  ''
