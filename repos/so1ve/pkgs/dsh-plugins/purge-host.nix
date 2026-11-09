{
  deepseek-harness,
  fetchzip,
}:

let
  source =
    (builtins.fromJSON (builtins.readFile ./manifest.json))."github:kingcharleslzy-ai/dsh-purge";

  purge = fetchzip {
    inherit (source) url hash;
    extension = "tar.gz";
  };
in
deepseek-harness.overrideAttrs (old: {
  pname = "deepseek-harness-purge";

  postInstall = (old.postInstall or "") + ''
    cp -r ${purge} "$TMPDIR/purge-source"
    chmod -R u+w "$TMPDIR/purge-source"
    ln -s "$out/share/deepseek-harness/node_modules" "$TMPDIR/purge-source/node_modules"

    DSH_HOME="$TMPDIR/purge-home" DSH_SURFACE=web \
      node ${./apply-purge.mjs} "$TMPDIR/purge-source" "$out/share/deepseek-harness"
  '';
})
