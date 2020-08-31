{ lib, libSuper }:

let
  # lib imports {{{1
  inherit (lib.trivial) #{{{2
    flip
    warn
  ;
  inherit (lib.fixedPoints) #{{{2
    extends
  ;
  inherit (lib.customisation) #{{{1
    makeScope # (mod)
  ; #}}}1
in {

  # makeScope {{{2
  /* Make a set of packages with a common scope.

     All packages called with the provided `callPackage` will be evaluated
     with the same arguments.

     Any package in the set may depend on any other.

     The `overrideScope'` function allows subsequent modification of the
     package set in a consistent way, i.e. all packages in the set will be
     called with the overridden packages.

     The package sets may be hierarchical: the packages in the set are called
     with the scope provided by `newScope` and the set provides a `newScope`
     attribute which can form the parent scope for later package sets.

     Type: let
       type MakeScope c p = (attrs -> c) -> ((attrs & p) -> p) -> (p & (p // {
         newScope = attrs -> c;
         callPackage = c;
         overrideScope' = ((q & (p // attrs)) -> p -> q) -> MakeScope c q;
         packages = p -> p;
       }));
     in MakeScope c p
  */
  makeScope =
    # Function given a scope to call scoped packages with
    newScope:
    # Function fixed on the new scope
    packages:
    let self = packages self // {
      # Function given an extending scope to call scoped packages with
      newScope = scope: newScope (self // scope);
      # Call a package with this scope
      callPackage = self.newScope { };
      overrideScope = flippedExtension: warn ''
        `overrideScope` (from `lib.makeScope`) is deprecated.
        STOP USING IT.'' (
          self.overrideScope' (flip flippedExtension)
        );
      # Overlay this scope
      overrideScope' = overlay:
        makeScope newScope (extends overlay packages);
      # Function fixed to create this scope
      inherit packages;
    }; in self;

  #}}}1

}
# vim:fdm=marker:fdl=1
