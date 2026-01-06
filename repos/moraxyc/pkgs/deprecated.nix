pkgs:
let
  upstreamed = [ "hmcl" ];
  discontinued = [ "gzctf" ];

  inherit (pkgs) lib;
in
lib.genAttrs upstreamed (n: throw "nur-moraxyc: ${n} has been upstreamed to nixpkgs.")
// lib.genAttrs discontinued (n: throw "nur-moraxyc: ${n} is no longer maintained in this NUR.")
