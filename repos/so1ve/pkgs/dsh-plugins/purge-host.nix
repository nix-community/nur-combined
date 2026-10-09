{
  callPackage,
  fetchzip,
  deepseek-harness ? callPackage ../deepseek-harness { },
}:

let
  source = (builtins.fromJSON (builtins.readFile ./manifest.json))."github:YuJunZhiXue/dsh-purge";

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

    DSH_HOME="$TMPDIR/purge-home" DSH_SURFACE=web \
      node ${./apply-purge.mjs} "$TMPDIR/purge-source" "$out/share/deepseek-harness"
  '';
})
