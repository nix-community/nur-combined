{
  pkgs,
}:

{
  unpackFile =
    { src }:
    pkgs.stdenv.mkDerivation {
      inherit src;
      name = "unpacked";
      nativeBuildInputs = [ pkgs.unzip ];
      sourceRoot = ".";
      buildPhase = ''
        mkdir -- $out
        mv -v ./* -- $out/
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    };
}
