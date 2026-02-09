pkgs:
let
  inherit (pkgs) lib;

  deprecatedPkgs = {
    # Upstreamed
    hmcl = "upstreamed";
    sub-store = "upstreamed";
    sub-store-frontend = "upstreamed";

    # Unmaintained
    exloli-next = "unmaintained";
  }
  // lib.mapAttrs (_n: _v: "discontinued") (lib.filesystem.readDir ./discontinued);

  reasonMap = {
    upstreamed = "has been upstreamed to nixpkgs";
    discontinued = "is no longer maintained in this NUR";
    unmaintained = "is no longer maintained by upstream";
  };
in
lib.mapAttrs (
  name: reasonKey: throw "nur-moraxyc: ${name} ${reasonMap.${reasonKey}}."
) deprecatedPkgs
