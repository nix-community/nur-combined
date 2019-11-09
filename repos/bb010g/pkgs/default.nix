{ pkgs, selfLib }:

let
  inherit (pkgs) lib;
  pythonPkgsScoped = self: super: {
    # so, this is cursed
    # we're going to override the root pythonInterpreters expression so
    # deriving other overrides is easier
    # (and we can share a dream of universal python overrides)
    pythonInterpreters = super.pythonInterpreters.override (o: {
      # we now are overriding the pkgs it uses in `with pkgs;` to access
      # callPackage
      pkgs = o.pkgs // {
        # which is pretty much only called to deal with
        # top-level/python-packages, so we hijack it for ourselves
        callPackage = fn: args: o.pkgs.callPackage fn (let
          # snatch away packageOverrides and force our own on
          packageOverrides = pySelf: pySuper:
            # walk backwards through the infinite recursion of lib.fix'
            pySuper.__extends__ or
              # until we can insert our scope-y selves at the root
              # and take advantage of the specific way python-packages seals
              # itself with overrides up
              (let pyScope = lib.makeScope self.newScope (self: pySuper // {
                # we reset callPackage for anyone inside to something sane
                # and under our scope's control
                inherit (self) callPackage;
              }); in if args ? packageOverrides then
                # and if someone specified some overrides, apply those in
                # the manner we desire now
                pyScope.overrideScope' args.packageOverrides
              else
                pyScope);

          # of course, only specify if fn can take it
          f = if lib.isFunction fn then fn else import fn;

          # (woo you can tell it's still good because we reimplemented a bit
          # of lib.callPackageWith just now)

          in if (lib.functionArgs f) ? packageOverrides then
            args // { inherit packageOverrides; }
          else
            args);
      };
    });
  };
in (pkgs.appendOverlays (builtins.concatLists [
  (lib.optional (!(pkgs.pythonPackages ? overrideScope')) pythonPkgsScoped)
])).callPackage ./top-level/all-packages.nix {
  lib = lib // (selfLib { inherit lib pkgs; });
}
