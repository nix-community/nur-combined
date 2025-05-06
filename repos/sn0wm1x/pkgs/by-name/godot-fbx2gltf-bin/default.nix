{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "fbx2gltf";
  version = "0.13.1";
  preferLocalBuild = true;

  src = fetchzip {
    url = "https://github.com/godotengine/FBX2glTF/releases/download/v${version}/FBX2glTF-linux-x86_64.zip";
    hash = "sha256-x9dqTYWICy5wfkZW9XpcOKR0FmespU9tS/4MDEMD0LM=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 $src/FBX2glTF-linux-x86_64 $out/bin/fbx2gltf
    runHook postInstall
  '';

  meta = {
    description = "A command-line tool for the conversion of the FBX file format to the glTF file format";
    homepage = "https://github.com/godotengine/FBX2glTF";
    changelog = "https://github.com/godotengine/FBX2glTF/releases/tag/v${version}";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.bsd3;
    mainProgram = "fbx2gltf";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = [ "x86_64-linux" ];
  };
}
