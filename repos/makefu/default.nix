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
    alsa-hdspconf = callPackage ./custom/alsa-tools { alsaToolTarget="hdspconf";};
    alsa-hdspmixer = callPackage ./custom/alsa-tools { alsaToolTarget="hdspmixer";};
    alsa-hdsploader = callPackage ./custom/alsa-tools { alsaToolTarget="hdsploader";};
    qcma = super.pkgs.libsForQt5.callPackage ./custom/qcma { };
    inherit (callPackage ./devpi {}) devpi-web ;
    nodemcu-uploader = super.pkgs.callPackage ./nodemcu-uploader {};
    inkscape = super.pkgs.stdenv.lib.overrideDerivation super.inkscape (old: {
      patches = [ ./custom/inkscape/dxf_fix.patch ];
    });
    pwqgen-ger = callPackage <stockholm/krebs/5pkgs/simple/passwdqc-utils> {
      wordset-file = super.pkgs.fetchurl {
        urls = [
          https://gist.githubusercontent.com/makefu/b56f5554c9ef03fe6e09878962e6fd8d/raw/1f147efec51325bc9f80c823bad8381d5b7252f6/wordset_4k.c
          https://archive.org/download/nixos-stockholm-tarballs/pviar5j1gxiqcf3l34b4n2pil06xc8zf-wordset_4k.c
        ];
        sha256 = "18ddzyh11bywrhzdkzvrl7nvgp5gdb4k1s0zxbz2bkhd14vi72bb";
      };
    };
}

// (mapAttrs (_: flip callPackage {})
            (filterAttrs (_: dir: pathExists (dir + "/default.nix"))
                         (subdirsOf ./.)))
