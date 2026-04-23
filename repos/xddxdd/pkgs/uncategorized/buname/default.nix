{
  sources,
  lib,
  stdenv,
  makeWrapper,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (sources.buname) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 buname.py $out/opt/buname.py
    makeWrapper ${lib.getExe python3} $out/bin/buname \
      --add-flags "$out/opt/buname.py"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Uname wrapper that renumbers Linux versions as if 2.6 never ended";
    homepage = "https://github.com/dramforever/buname";
    license = lib.licenses.unfree;
    mainProgram = "buname";
    platforms = lib.platforms.linux;
  };
})
