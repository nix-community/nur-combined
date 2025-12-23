pkgs:
let
  upstreamed = [ "hmcl" ];

  inherit (pkgs) lib;
in
lib.genAttrs upstreamed (n: throw "nur-moraxyc: ${n} has been upstreamed to nixpkgs.")
