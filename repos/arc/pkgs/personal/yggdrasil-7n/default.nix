let
  patchPackage = lib: pkg:
    lib.drvExec "bin/${pkg.pname}" (pkg.overrideAttrs (old: {
      pname = "${old.pname}-7n";
      patches = [ ./7n.patch ];
    }));
in {
  yggdrasil-7n = { yggdrasil, lib }: patchPackage lib yggdrasil;
  yggdrasilctl-7n = { yggdrasilctl, lib }: patchPackage lib yggdrasilctl;
}
