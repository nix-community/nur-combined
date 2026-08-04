{ buildJosmPlugin
, fetchFromCodeberg
, gitUpdater
, lib
}:

let
  inherit (lib) licenses;
in
buildJosmPlugin (josm-imagery-used: {
  pname = "josm-imagery-used";
  version = "0.0.1";
  meta = {
    description = "JOSM plugin to populate imagery_used in changesets";
    homepage = "https://codeberg.org/AndrewKvalheim/imagery_used";
    license = licenses.gpl3;
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromCodeberg {
    owner = "AndrewKvalheim";
    repo = "imagery_used";
    rev = "refs/tags/v${josm-imagery-used.version}";
    hash = "sha256-JGYKN9ggUom48StabPoswoYymJiMo7tpXv/t2Ithurg=";
  };

  pluginName = "imagery_used";
})
