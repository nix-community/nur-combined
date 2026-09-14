{
  cronet-go,
}:

cronet-go.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "150.0.7871.63-3";

  src = previousAttrs.src.override {
    rev = "049f2909701ca088c9569f6b303bba5376a2b2ff";
    hash = "sha256-705cctVHseRSJuEPFxlTRJJUWsNgZ4y5ZQ9nwhyTqFY=";
  };
})
