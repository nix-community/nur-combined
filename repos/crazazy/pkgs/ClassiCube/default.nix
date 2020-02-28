# TODO: ClassiCube is still getting stuck on the "initializing font cache" dialog. I do not know of a way to fix this
# we have to wait and see if this becomes configurable before we can actually install this package
{gcc, curl, freetype, openal, libGL, SDL2, xorg, stdenv, fetchFromGitHub, writeScriptBin, lib}:
rec {
  classicCube = stdenv.mkDerivation rec {
    name = "ClassiCube";
    version = "1.1.2";
    src = fetchFromGitHub {
      repo = name;
      owner = "UnknownShadow200";
      rev = version;
      sha256 = "1xir6slwrgzma9m5gmv4nw81ihz40vr57cks76sgghanablzig00";
    };
    preBuild = ''
      cd ./src
    '';
    installPhase = ''
      install -D ClassiCube $out/bin/ClassiCube
      '';
    nativeBuildInputs = [ gcc ];
    buildInputs = [freetype openal curl libGL SDL2 xorg.libX11]; 
    meta = with lib; {
      description = "Custom Minecraft Classic / ClassiCube client written in C (formerly ClassicalSharp in C#) from scratch.";
      homepage = https://github.com/UnknownShadow200/ClassiCube;
      license = licenses.mit;
      platforms = platforms.linux ++ platforms.darwin;
    };

  };
  classicCubeRunner = writeScriptBin "ClassiCube" ''
    mkdir -p ${builtins.getEnv "HOME"}/.local/ClassiCube
    ${classicCube}/bin/ClassiCube -d${builtins.getEnv "HOME"}/.local/ClassiCube
  '';}.classicCubeRunner
