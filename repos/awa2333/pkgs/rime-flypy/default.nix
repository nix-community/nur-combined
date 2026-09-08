{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  librime,
  rime-data,
}:
stdenvNoCC.mkDerivation rec {
  name = "rime-flypy";
  version = "20251211";
  src = fetchFromGitHub {
    owner = "cubercsl";
    repo = name;
    tag = "v${version}";
    hash = "sha256-Lw54pNXUzsVv9OFp7c5Bf+pCCA0DWTslSTrN/raX9CM=";
  };
  preBuild = ''
    cp ${rime-data}/share/rime-data/*.yaml .
  '';
  makeFlags = [
    "PREFIX=$(out)"
  ];
  nativeBuildInputs = [
    librime
  ];
  meta = {
    description = "flypy schema for rime. (小鹤音形 rime 挂接文件)";
    homepage = "https://flypy.cc";
    platforms = lib.platforms.all;
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
