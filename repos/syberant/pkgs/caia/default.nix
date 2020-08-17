{ symlinkJoin, coreutils, findutils, gnugrep, makeWrapper, caia-unwrapped }:

symlinkJoin {
  name = "caia";
  buildInputs = [ makeWrapper ];
  paths = [ caia-unwrapped ];

  postBuild = let bindir = "${caia-unwrapped}/caia/zuniq/bin";
  in ''
    wrapProgram "$out/bin/caiaio" \
      --set PATH "${coreutils}/bin" \
      --run "mkdir -p /tmp/caia/{player,referee}logs" \
      --add-flags "-m ${bindir}/manager" \
      --set CAIA_BIN_DIR "${bindir}"

    cp $out/caia/zuniq/bin/competition.sh $out/bin/competition.sh
    chmod +x $out/bin/competition.sh
    patch $out/bin/competition.sh ${./competition-patch.diff}

    wrapProgram "$out/bin/competition.sh" \
      --set PATH "${coreutils}/bin:${findutils}/bin:${gnugrep}/bin" \
      --run "mkdir -p /tmp/caia/{player,referee}logs" \
      --set CAIA_BIN_DIR "${bindir}" \
      --set BASE "/tmp/caia"
  '';
}
