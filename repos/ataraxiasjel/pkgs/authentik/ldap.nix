{ buildGoModule, authentik }:

buildGoModule {
  pname = "authentik-ldap-outpost";
  inherit (authentik) version src;

  vendorHash = "sha256-8F9emmQmbe7R+xtGrjV5ht0adGasU6WAvLa8Wxr+j8M=";

  CGO_ENABLED = 0;

  subPackages = [ "cmd/ldap" ];

  meta = authentik.meta // {
    description = "The authentik ldap outpost. Needed for the extendal ldap API.";
    homepage = "https://goauthentik.io/docs/providers/ldap/";
    mainProgram = "ldap";
  };
}
