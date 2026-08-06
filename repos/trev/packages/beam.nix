{
  beamPackages,
}:
rec {
  hpax = beamPackages.callPackage ./hpax { };
  jason = beamPackages.callPackage ./jason { };
  mime = beamPackages.callPackage ./mime { };
  nimble_options = beamPackages.callPackage ./nimble_options { };
  nimble_pool = beamPackages.callPackage ./nimble_pool { };
  telemetry = beamPackages.callPackage ./telemetry { };
  typed_struct = beamPackages.callPackage ./typed_struct { };

  mint = beamPackages.callPackage ./mint { inherit hpax; };

  finch = beamPackages.callPackage ./finch {
    inherit
      hpax
      mime
      mint
      nimble_options
      nimble_pool
      telemetry
      ;
  };

  req = beamPackages.callPackage ./req {
    inherit
      finch
      jason
      mime
      ;
  };

  burrito = beamPackages.callPackage ./burrito {
    inherit
      jason
      req
      typed_struct
      ;
  };
}
