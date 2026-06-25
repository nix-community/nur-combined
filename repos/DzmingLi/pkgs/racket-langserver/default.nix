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
    nativeBuildInputs = [ racket cacert ];

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
      cp -r "$PLTADDONDIR/." "$out/"
      # Drop any straggler compiled artifacts; FOD outputs cannot have
      # /nix/store references.
      find "$out" -type d -name compiled -exec rm -rf {} + 2>/dev/null || true
      find "$out" -type f \( -name '*.zo' -o -name '*.dep' \) -delete 2>/dev/null || true
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-Eny0e55Lexm5gA2x8RWNOKb+EvQtD6i0LV84f8YQ4uI=";
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
    cp -r --no-preserve=mode ${addon} $out/share/racket
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
