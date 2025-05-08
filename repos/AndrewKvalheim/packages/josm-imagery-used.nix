{ buildJosmPlugin
, fetchFromGitea
, gitUpdater
, lib
}:

buildJosmPlugin (josm-imagery-used: {
  pname = "josm-imagery-used";
  version = "0.0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "imagery_used";
    rev = "refs/tags/v${josm-imagery-used.version}";
    hash = "sha256-JGYKN9ggUom48StabPoswoYymJiMo7tpXv/t2Ithurg=";
  };

  pluginName = "imagery_used";

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "JOSM plugin to populate imagery_used in changesets";
    homepage = "https://codeberg.org/AndrewKvalheim/imagery_used";
    license = lib.licenses.gpl3;
  };
})
