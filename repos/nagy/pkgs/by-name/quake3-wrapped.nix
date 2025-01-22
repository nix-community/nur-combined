{ quake3wrapper, stdenvNoCC, requireFile, quake3pointrelease }:

let
  quake3_pak0 = stdenvNoCC.mkDerivation {
    name = "quake3-arena-pak0-file";
    # TODO replace with linkfarm
    # :b linkFarm "myexample" [ { name = "baseq3/pak0.pk3"; path = self.quake3_pak0; } ]
    # name = "pak0.pk3";
    pak0 = requireFile {
      # nix-store --add-fixed sha256 pak0.pk3
      name = "pak0.pk3";
      hash = "sha256-fOizkQYgzVCgnk8RAPQm6MYYD2iJXVifgOa9la9UvK4=";
    };
    buildCommand = ''
      mkdir -p $out/baseq3
      ln -s $pak0 $out/baseq3/pak0.pk3
    '';
  };
in
quake3wrapper {
  name = "quake3-arena";
  paks = [ quake3pointrelease quake3_pak0 ];
}
