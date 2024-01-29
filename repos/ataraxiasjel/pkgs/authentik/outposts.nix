{ callPackage, authentik }:

{
  ldap = callPackage ./ldap.nix { inherit authentik; };
}
