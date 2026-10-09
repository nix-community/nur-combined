{
  # keep-sorted start
  fetchurl,
  stdenv,
  zig,
  # keep-sorted end
}:
stdenv.mkDerivation {
  pname = "usage-core";
  version = "0.1.0";

  src = fetchurl {
    url = "https://api.next.tangled.org/xrpc/org.tangled.temp.git.getArchive?repo=did%3Aplc%3A2lf7buutfnfcucljnmaypf7u&ref=1a4bff9&format=tar.gz&prefix=provide-usage-main";
    hash = "sha256-IkKxwP9jTEy3px93EWbRRx44KsYClaAOvtXgEfJ4kew=";
  };

  sourceRoot = "provide-usage-main";

  nativeBuildInputs = [zig];

  # The knot serves the archive with a query string, so the store path has no
  # extension for unpackPhase to sniff: one explicit tar it is.
  unpackPhase = ''
    runHook preUnpack

    tar -xzf $src

    runHook postUnpack
  '';

  # The build.zig ranlib step hardcodes zig-out, so the default prefix it is
  # (no --prefix): artifacts are copied out in installPhase instead.
  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    zig build --cache-dir "$TMPDIR/zig-cache" --global-cache-dir "$TMPDIR/zig-global-cache"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-out/bin/usage $out/bin/usage

    runHook postInstall
  '';
}
