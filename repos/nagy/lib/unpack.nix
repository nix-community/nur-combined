{
  pkgs,
}:

{
  unpackFile =
    { src }:
    pkgs.stdenv.mkDerivation {
      name = "unpacked";
      inherit src;
      nativeBuildInputs = [ pkgs.unzip ];
      sourceRoot = ".";
      buildPhase = ''
        runHook preBuild

        mkdir -- $out
        mv -v -- ./* $out/

        runHook postBuild
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    };
}
