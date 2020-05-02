import ./generic.nix ({ lib,
... } @ args: self: super: {
  version = "1.0.0";

  src = super.src // {
    sha256 = "188lhyaxb9800s11ih13mh1mxf6pa2m6r2m6l16jgwlal7k1yp11";
  };

  cargoSha256 = "0qcj39ljd331k45vf2yrqv64pw7cimgdnvwhfzqp93xqild4qdpn";
})
