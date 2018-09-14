self: super:

let

  hydraBase = super.hydra.override {
    nix = super.nixUnstable;
  };

in

  {
    hydra = hydraBase.overrideAttrs (_: {
      patches = [ ./hydra-restricted-eval.patch ];
      doCheck = false;
    });
  }
