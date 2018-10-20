self: super: 
with super.lib; with builtins; let
  # This callPackage will try to detect obsolete overrides.
  callPackage = path: args: let
    override =  super.callPackage path args;
    upstream = optionalAttrs (override ? "name")
      (super.${(parseDrvName override.name).name} or {});
  in if upstream ? "name" &&
        override ? "name" &&
        compareVersions upstream.name override.name != -1
    then
      trace
        "Upstream `${upstream.name}' gets overridden by `${override.name}'."
        override
    else override;

   eq = x: y: x == y;
   subdirsOf = path:
     mapAttrs (name: _: path + "/${name}")
              (filterAttrs (_: eq "directory") (readDir path));

in {
    quodlibet = super.pkgs.stdenv.lib.overrideDerivation super.quodlibet (old: {
      patches = [ ./custom/quodlibet/single-digit-discnumber.patch
                  ./custom/quodlibet/remove-override-warning.patch ];
    });
    alsa-hdspconf = callPackage ./custom/alsa-tools { alsaToolTarget="hdspconf";};
    alsa-hdspmixer = callPackage ./custom/alsa-tools { alsaToolTarget="hdspmixer";};
    alsa-hdsploader = callPackage ./custom/alsa-tools { alsaToolTarget="hdsploader";};
    qcma = super.pkgs.libsForQt5.callPackage ./custom/qcma { };
    inherit (callPackage ./devpi {}) devpi-web ;
    nodemcu-uploader = super.pkgs.callPackage ./nodemcu-uploader {};
}

// (mapAttrs (_: flip callPackage {})
            (filterAttrs (_: dir: pathExists (dir + "/default.nix"))
                         (subdirsOf ./.)))
