{ stdenv, mkDerivation, qmake, qttools, qtbase, fetchFromGitHub, autoPatchelfHook, wrapQtAppsHook }:
let
  platformToDir = platform:
    if platform.isLinux && platform.isx86_32
    then "Linux_x86_32"
    else if platform.isLinux && platform.isx86_64
    then "Linux_x86_64"
    else "OSX_x86";
in
mkDerivation {
  pname = "SpriteSheetPacker";
  version = "master-2020-06-22";
  src = fetchFromGitHub {
    owner = "amakaseev";
    repo = "sprite-sheet-packer";
    rev = "a55f3bc10f9617e54312976e1c3c65e30ea30c06";
    sha256 = "sha256-TyXQcZD5SV/dl212P+iFUTLtLoDSV81CviFT9lYz+Rc=";
  };
  buildInputs = [ qtbase stdenv.cc.cc.lib ];
  nativeBuildInputs = [ qmake qttools autoPatchelfHook ];
  patches = [ ./0001-remove-deploy.patch ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp install/linux/bin/SpriteSheetPacker $out/bin
    cp -r SpriteSheetPacker/defaultFormats $out/bin
    cp SpriteSheetPacker/3rdparty/PVRTexTool/${platformToDir stdenv.hostPlatform}/libPVRTexLib.so $out/lib
  '';
  meta = with stdenv.lib; {
    description = "Sprite sheet generator based on Qt";
    homepage = "https://amakaseev.github.io/sprite-sheet-packer/";
    license = licenses.unfree; # Some parts of output are not free redistributable
    platforms = with platforms; darwin ++ linux;
  };
}
