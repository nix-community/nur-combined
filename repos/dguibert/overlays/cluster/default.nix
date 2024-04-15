final: prev:
with prev; {
  lib = prev.lib.extend (final': prev':
    with final'; {
      fetchers = import ./lib/fetchers.nix {lib = prev';};
      tryUpstream = drv: attrs:
        builtins.trace "broken upstream ${drv.name}" (drv.overrideAttrs attrs).overrideAttrs (o: {
          isBroken = isBroken drv;
        });
      # https://nixos.org/manual/nix/stable/language/builtins.html#builtins-tryEval
      #let e = { x = throw ""; }; in (builtins.tryEval (builtins.deepSeq e e)).success
      #if (builtins.tryEval (isBroken drv)).success
      #then (isBroken drv) # should fail and use our override
      #else drv.overrideAttrs attrs;
      dontCheck = drv:
        drv.overrideAttrs (o: {
          doCheck = false;
          doInstallCheck = false;
        });
      upstreamFails = drv:
        if ! (final.nixStore == "/nix")
        then
          tryUpstream drv (o: {
            doCheck = false;
            doInstallCheck = false;
          })
        else drv;

      narHash = pkg: version: hash:
        builtins.trace "${pkg.name} with new hash: ${hash}" lib.upgradeOverride pkg (_: {
          inherit version;
          src = pkg.src.overrideAttrs (_: {
            outputHash = hash;
          });
        });
    });

  #nix = if nixStore == "/nix" then prev.nix
  #  else final.lib.upstreamFails prev.nix;
  nix = final.lib.dontCheck prev.nix;
  nix_2_3 = final.lib.upstreamFails prev.nix_2_3;
  nixStable = final.lib.upstreamFails prev.nixStable;
  nixos-option = null;
  fish = final.lib.dontCheck prev.fish;

  openssh = final.lib.dontCheck prev.openssh;

  pythonOverrides = prev.lib.composeOverlays [
    (prev.pythonOverrides or (_:_: {}))
    (python-self: python-super: {
      annexremote = final.lib.narHash python-super.annexremote "1.6.0" "sha256-h03gkRAMmOq35zzAq/OuctJwPAbP0Idu4Lmeu0RycDc=";
      #dnspython = final.lib.upstreamFails python-super.dnspython;
      flit-scm = final.lib.narHash python-super.flit-scm "1.7.0" "sha256-2nx9kWq/2TzauOW+c67g9a3JZ2dhBM4QzKyK/sqWOPo=";
    })
  ];
}
