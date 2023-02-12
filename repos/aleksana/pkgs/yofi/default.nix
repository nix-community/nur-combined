{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  wayland,
  libxkbcommon,
  fontconfig,
  graphite2,
}:

rustPlatform.buildRustPackage rec {
  pname = "yofi";
  version = "0.2.0";
  
  src = fetchFromGitHub {
    owner = "l4l";
    repo = "${pname}";
    rev = "3b625d306e14dfcf7c497bc418b36c673642fe9d";
    hash = "sha256-aaTT4BInCi3iVt4jwnZpmnOWH+RNL4lHMTkiTPvIIWs=";
  };
  
  cargoHash = "sha256-WhZggPhfVc/fLHOkpQKwPTNK49mfrfgQfkUu/wFDM30=";
  
  buildInputs = [ wayland libxkbcommon fontconfig ];
  
  nativeBuildInputs = [ makeWrapper ];
  
  postInstall = ''
    wrapProgram $out/bin/yofi \
      --prefix LD_LIBRARY_PATH : ${wayland}/lib \
      --prefix LD_LIBRARY_PATH : ${fontconfig.lib}/lib \
      --prefix LD_LIBRARY_PATH : ${libxkbcommon}/lib
  '';
  
  meta = with lib; {
    description = "A minimalistic menu for wayland. ";
    homepage = "https://github.com/l4l/${pname}";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
