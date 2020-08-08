{ symlinkJoin, makeWrapper, caia-unwrapped }:

symlinkJoin {
  name = "caia";
  buildInputs = [ makeWrapper ];
  paths = [ caia-unwrapped ];

  postBuild = let bindir = "${caia-unwrapped}/caia/zuniq/bin";
  in ''
    wrapProgram "$out/bin/caiaio" \
      --add-flags "-m ${bindir}/manager" \
      --set CAIA_BIN_DIR "${bindir}"
  '';
}
