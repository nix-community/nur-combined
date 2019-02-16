self: super:

{
  hydra = super.hydra.overrideAttrs (old: {
    patches = old.patches ++ [ ./hydra-restricted-eval.patch ];
    doCheck = false;
  });
}
