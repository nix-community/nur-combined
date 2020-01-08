{ godot, fetchFromGitHub }:

let
  voxel = fetchFromGitHub {
    owner = "Zylann";
    repo = "godot_voxel";
    rev = "14035887fce070e49e5492244920676784c2f23d";
    sha256 = "0cdq7pp543p7wmiwx81lc1fs4h104q4h0x6g8zjk97wf96sw0a8n";
  };
in godot.overrideAttrs (attrs: {
  postUnpack = ''
    cp -r "${voxel}" source/modules/voxel
    chmod u+w -R source/modules/voxel
  '';
})
