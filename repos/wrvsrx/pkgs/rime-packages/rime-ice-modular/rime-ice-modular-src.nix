{
  stdenvNoCC,
  haskellPackages,
  source,
}:
stdenvNoCC.mkDerivation {
  inherit (source) pname src version;
  env.LANG = "C.UTF-8";
  nativeBuildInputs = [
    (haskellPackages.ghcWithPackages (
      ps: with ps; [
        yaml
        shake
        raw-strings-qq
        extra
        utf8-string
        aeson-pretty
      ]
    ))
  ];
  buildPhase = ''
    shake
  '';
  installPhase = ''
    mkdir -p $out
    cp -r build/* $out/
  '';
}
