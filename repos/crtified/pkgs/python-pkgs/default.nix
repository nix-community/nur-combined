{ callPackage }:
rec {
  ldap0 = callPackage ./ldap0 { };
  web2ldap = callPackage ./web2ldap {
    inherit ldap0;
  };
}
