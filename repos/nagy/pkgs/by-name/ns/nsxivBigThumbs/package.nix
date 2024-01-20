{ nsxiv, fetchpatch, fetchFromGitea }:

nsxiv.overrideAttrs ({ src, patches ? [ ], postPatch ? "", ... }: {
  # old version because patches are not updated yet.
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "nsxiv";
    repo = "nsxiv";
    rev = "v31";
    hash = "sha256-X1ZMr5OADs9GIe/kp/kEqKMMHZMymd58m9+f0SPzn7s=";
  };
  patches = patches ++ [
    (fetchpatch {
      url =
        "https://codeberg.org/nsxiv/nsxiv-extra/raw/branch/master/patches/square-thumbs/square-thumbs-v31.diff";
      hash = "sha256-exY30/MxWInO5hTRSyxM5H5zv0bj2aAZpODWlJ31IyE=";
    })
  ];
  postPatch = postPatch + ''
    # increase thumbnail sizes
    substituteInPlace config.def.h \
      --replace '96, 128, 160' '96, 128, 160, 320, 640'  \
      --replace 'THUMB_SIZE = 3' 'THUMB_SIZE = 5'  \
      --replace 'SQUARE_THUMBS = false' 'SQUARE_THUMBS = true'
  '';
})
