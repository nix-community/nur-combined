{
  stdenvNoCC,
  fcitx5-rime,
  zstd,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-fcitx5";
  # for unzip source files
  nativeBuildInputs = [ zstd ];
  inherit (fcitx5-rime) src version;
  installPhase = ''
    install --mode=644 -D data/fcitx5.yaml $out/share/rime-data/fcitx5.yaml
    install --mode=644 -D data/fcitx5.yaml $out/share/rime-data/build/fcitx5.yaml
  '';
}
