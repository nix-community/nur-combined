{
  lib,
  buildPythonPackage,
  pins,
  numpy,
  python-sat,
  luaparser,
  pygame,
  pillow,
  pyopengl,
  graphviz,
  ffmpeg-python,
  factorio,
}:

buildPythonPackage rec {
  pname = "factorio-sat";
  version = pins.factorio-sat.rev;

  src = pins.factorio-sat.outPath;

  propagatedBuildInputs = [
    numpy
    python-sat
    luaparser
    pygame
    pillow
    pyopengl
    graphviz
    ffmpeg-python
  ];

  postInstall = ''
    $out/bin/fetch_assets ${factorio.outPath}/share/factorio/
  '';

  meta = with lib; {
    description = "Produce belt balancer designs using SAT solvers";
    homepage = "https://github.com/R-O-C-K-E-T/Factorio-SAT";
    maintainers = with maintainers; [ arobyn ];
    license = licenses.gpl3;
  };
}
