self: super:

{
  hydra = super.hydra.overrideAttrs (_: {
    patches = [ ./hydra-restricted-eval.patch ];
  });
}
