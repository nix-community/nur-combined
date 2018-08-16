self: super:

{
  termite-unwrapped = super.termite-unwrapped.overrideAttrs (old: {
    patches = old.patches ++ [ ./termite-no-f11-flag.patch ];
  });
}
