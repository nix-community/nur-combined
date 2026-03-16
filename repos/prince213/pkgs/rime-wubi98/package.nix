{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-wubi98";
  version = "0-unstable-2025-07-10";

  src = fetchFromGitHub {
    owner = "yanhuacuo";
    repo = "98wubi";
    rev = "7fa4a71f62af840c182a7a5417ba5090d0054bf8";
    hash = "sha256-M/QMusumOOVypo8Mlm3Kq0Avz98rAcEntjCLs9LziM0=";
  };

  postPatch = ''
    for i in *.extended.dict.yaml; do
      sed -i '/\.\.\./q' $i
    done
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp -r icons lua $out/share/rime-data
    install -Dm644 -t $out/share/rime-data \
      rime.lua \
      {py,wb_spelling}.{dict,schema}.yaml \
      wubi98_{ci,dz,U}.{dict,extended.dict,schema}.yaml

    runHook postInstall
  '';

  meta = {
    description = "Wubi98 schemas for RIME";
    homepage = "https://github.com/yanhuacuo/98wubi";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
