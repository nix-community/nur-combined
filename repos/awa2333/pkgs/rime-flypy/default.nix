{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  librime,
  rime-data,
}:
stdenvNoCC.mkDerivation rec {
  name = "rime-flypy";
  version = "20240827";
  src = fetchFromGitHub {
    owner = "cubercsl";
    repo = name;
    tag = "v${version}";
    hash = "sha256-shXcDjAaClemaOsE9ajZBedUzYKLw+ZATDTuyAu+zUc=";
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
