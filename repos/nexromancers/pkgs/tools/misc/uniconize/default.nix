import ./generic.nix ({ lib,
... } @ args: self: super: {
  version = "1.0.0";

  src = super.src // {
    sha256 = "188lhyaxb9800s11ih13mh1mxf6pa2m6r2m6l16jgwlal7k1yp11";
  };

  cargoSha256 = "1gsmn1p7dljsqvfcvk6jp5519fpyzdnxijpmlsbrm42zpzwfjv6q";
})
