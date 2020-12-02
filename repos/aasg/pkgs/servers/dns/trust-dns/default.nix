{ lib
, callPackage
, defaultCrateOverrides
, features ? [ ]
}:

(callPackage ./Cargo.nix { }).workspaceMembers.trust-dns.build.override {
  inherit features;
  crateOverrides = defaultCrateOverrides // {
    trust-dns = attrs: {
      meta = with lib; {
        description = "Rust-based DNS client, server, and resolver";
        homepage = "https://github.com/bluejekyll/trust-dns";
        license = licenses.mit;
        maintainers = with maintainers; [ AluisioASG ];
        platforms = platforms.all;
      };
    };
  };
}
