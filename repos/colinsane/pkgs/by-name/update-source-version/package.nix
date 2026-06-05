{
  common-updater-scripts,
}: common-updater-scripts.overrideAttrs (upstream: {
  name = "update-source-version";
  # XXX(2026-01-23): upstream package does not follow standard packaging idioms; no opportunity to patch earlier.
  #
  # allow `update-source-version` to reliably perform IFD.
  # by default, `nix-instantiate --eval -A ATTR` can't realize derivations in the process of evaluating `ATTR`.
  # but in the context of updating, there's a good chance it'll need to instantiate a (new) copy of `nixpkgs`
  # in order to access `ATTR`, so allow it -- via `--read-write-mode` flag.
  postFixup = (upstream.postFixup or "") + ''
    mv $out staging

    substituteInPlace staging/bin/.update-source-version-wrapped \
      --replace-fail 'nix-instantiate ' 'nix-instantiate --read-write-mode'

    mkdir -p $out/bin
    cp staging/bin/{update-source-version,.update-source-version-wrapped} $out/bin
  '';
})
