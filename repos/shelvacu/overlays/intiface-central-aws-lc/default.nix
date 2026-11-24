final: prev: {
  # backport of nixpkgs 377250c1049d; cargo-setup-hook sets AWS_LC_SYS_USE_SYSTEM=1
  intiface-central =
    if
      prev.intiface-central.version == "3.2.2+46"
      && !(builtins.elem final.aws-lc prev.intiface-central.buildInputs)
    then
      (prev.intiface-central.override (old: {
        # the rust lib is let-bound, so reach it through buildRustPackage
        rustPlatform = old.rustPlatform // {
          buildRustPackage =
            args:
            old.rustPlatform.buildRustPackage (
              args // { buildInputs = (args.buildInputs or [ ]) ++ [ final.aws-lc ]; }
            );
        };
      })).overrideAttrs
        (old: {
          buildInputs = old.buildInputs ++ [ final.aws-lc ];
        })
    else
      prev.intiface-central;
}
