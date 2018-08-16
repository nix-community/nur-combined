self: super:

{
  hydra = super.hydra.overrideAttrs (_: {
    patches = [ ./patches/hydra-eval.patch ];
  });
}
