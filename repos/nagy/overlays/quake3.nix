self: super: {
  quake3_pak0 = super.stdenvNoCC.mkDerivation {
    name = "quake3-arena-pak0-file";
    # TODO replace with linkfarm
    # :b linkFarm "myexample" [ { name = "baseq3/pak0.pk3"; path = self.quake3_pak0; } ]
    # name = "pak0.pk3";
    pak0 = super.requireFile {
      # nix-store --add-fixed sha256 pak0.pk3
      message = "You need to add pak0.pk3 to the nix store";
      name = "pak0.pk3";
      sha256 = "1bmwajprbgg6h2gmhpc9d07iiip84vs004agksh51k900s8v7s3w";
    };
    # passthru.pak0 = pak0;
    buildCommand = ''
      mkdir -p $out/baseq3
      ln -s $pak0 $out/baseq3/pak0.pk3
    '';
  };

  quake3 = super.quake3wrapper {
    name = "quake3-arena";
    paks = [ super.quake3pointrelease self.quake3_pak0 ];
  };
}
