{ runCommand, svf, graphviz, makeFontsConf, freefont_ttf }:

let
  svfUlimit = "ulimit -St 900 -Ht 900 -Hv 4096000 -Sv 4096000";
  dotUlimit = "ulimit -St 600 -Ht 600";

  # O:)
  optionalAttrs = cond: attrs: if cond then attrs else {};
  optionalString = cond: str: if cond then str else "";
  recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };
in
rec {
  runsvf_on = bc: opts: runCommand "runsvf" {
    buildInputs = [ svf ];
  } ''
    mkdir -p $out
    cd $out

    # Symlink because wpa wants to write relative to input file
    ln -s ${bc} ./input.bc
    ${svfUlimit}
    wpa ${opts} ./input.bc |& tee output.log

    mkdir -p $out/nix-support
    for x in $out/*.dot; do
      echo "file dot $x" >> $out/nix-support/hydra-build-products
    done
  '';

  fontsConf = makeFontsConf { fontDirectories = [ freefont_ttf ]; };

  graphviz_cmd = {
    name,
    input,
    outName,
    layout ? "dot",
    fmt ? "svg",
    options ? "",
  }:
    runCommand "${name}-${layout}-${fmt}-${outName}" { buildInputs = [ graphviz ]; } (''
      export FONTCONFIG_FILE=${fontsConf}
      ${dotUlimit}

      mkdir -p $out
      dot -K${layout} -T${fmt} ${input} -o $out/${outName} ${options}

      mkdir -p $out/nix-support
      echo "file svg $out/${outName}" >> $out/nix-support/hydra-build-products
  '');
  #  + optionalString (fmt == "svg") ''
  #    ${svgo}/bin/svgo $out/${outName}
  #'');

  svgs_fn = name: input:
    let gvcmd = args: graphviz_cmd ({
      inherit name input;
      fmt = "svg";
      outName = "${name}.svg";
    } // args); in {
    dot_ortho = gvcmd { layout = "dot"; options = "-Gsplines=ortho -Goverlap=prism -Granksep=3 -Gpackmode=graph"; };
    dot = gvcmd { layout = "dot"; options = "-Gconcentrate=true -Goverlap=prism -Granksep=3 -Gpackmode=graph"; };
    sfdp = gvcmd { layout = "sfdp"; options = "-Goverlap=false";};
    circo = gvcmd { layout = "circo"; };
    neato = gvcmd { layout = "neato"; options = "-Goverlap=prism -Gmode=hier"; };
    twopi = gvcmd { layout = "twopi"; options = "-Goverlap=prism -Granksep=5 -Gesep=0.5 -Gsep='+20' -Gsplines=true -Gconcentrate=true"; };
  };

  analyze_fn = bc: let runsvf = runsvf_on bc; in recurseIntoAttrs rec {
    # inherit bc;
    ander = runsvf "-ander -write-ander=ander.save -dump-pag -dump-consG -dump-callgraph";
    fspta = runsvf "-fspta -dump-pag -dump-consG -dump-callgraph";

    # XXX: -write-ander/-read-ander seems to work, but unsure if always (or ever?) equivalent..
    svfg_data = runsvf "-ander -read-ander=${ander}/ander.save -svfg -dump-svfg";
    fspta_svfg_data = runsvf "-fspta -svfg -dump-svfg";

    #callgraph_direct_data = runCommand "callgraph_indirect_noconstraint" {} ''
    #  mkdir -p $out
    #  cp -r ${ander}/callgraph* $out

    #  for x in $out/callgraph*; do
    #    substituteInPlace $x --replace "color=red" "color=red,constraint=false,weight=0"
    #    substituteInPlace $x --replace 'label="{main}"' 'label="{main}",root=true'
    #  done
    # '';

    pag = (svgs_fn "pag" "${ander}/pag_final.dot").dot;

    # Say this one three times fast!
    # svfg = svgs_fn "svfg" "${svfg_data}/ander_svfg.dot"; # XXX: Not sure which should be used
    # fspta_svfg = svgs_fn "svfg" "${fspta_svfg_data}/ander_svfg.dot"; # XXX: Not sure which should be used



    callgraph = recurseIntoAttrs {
      inherit (svgs_fn "callgraph" "${ander}/callgraph_final.dot") dot twopi;
    };
    fspta_callgraph = recurseIntoAttrs {
      inherit (svgs_fn "callgraph" "${fspta}/callgraph_final.dot") dot twopi;
    };
  };
  #// optionalAttrs (!graphsOnly) {
  #  pag_consg = runsvf "-nander -dump-pag -dump-consG";

  #  mssa = runsvf "-ander -svfg -dump-mssa";

  #  pta_fspta = runsvf "-fspta -stat";# -print-pts";
  #  pta_ander = runsvf "-ander -stat";# -print-pts";
  #  pta_nander = runsvf "-nander -stat";# -print-pts";
  #};
}
