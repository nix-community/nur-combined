{
  lib,
  makeWrapper,
  symlinkJoin,
  gt3-revisited-unwrapped,
  fetchurl,
  image ? (
    fetchurl {
      name = "Gran_Turismo_3_A-Spec__Japan_.iso";
      url = "https://dn721608.ca.archive.org/0/items/gran-turismo-3-a-spec-japan/Gran%20Turismo%203%20A-Spec%20%28Japan%29.iso";
      hash = "sha256-OfF+VV4OtLW08hHLUT98/F4PLPEawuyaPsUVnep2wzA=";
    }
  ),
}:

symlinkJoin {
  name = "gt3-revisited-${gt3-revisited-unwrapped.version}";

  paths = [ gt3-revisited-unwrapped ];

  nativeBuildInputs = [ makeWrapper ];

  # gt3r takes the disc from a positional argument and the last one wins, so
  # the image given here comes first: it is what the game opens unless another
  # image is named on the command line.
  postBuild = ''
    wrapProgram $out/bin/gt3r ${
      lib.optionalString (image != null) "--add-flags ${lib.escapeShellArg (toString image)}"
    }
  '';

  passthru = {
    inherit image;
    unwrapped = gt3-revisited-unwrapped;
  };

  meta = gt3-revisited-unwrapped.meta // {
    longDescription = ''
      GT3 Revisited reimplements the Gran Turismo 3 A-Spec engine for modern
      platforms. It contains no game data: the disc image you made from your
      copy is opened by `gt3r`, either at run time with the image on its
      command line (`gt3r /path/to/image.iso`) or, when it was set with
      `gt3-revisited.override { image = …; }`, without an argument.
      `gt3-revisited-unwrapped` is the same build without the wrapper.
    '';
  };
}
