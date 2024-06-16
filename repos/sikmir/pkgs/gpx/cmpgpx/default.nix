{
  lib,
  fetchFromGitHub,
  python3Packages,
  geotiler,
}:

python3Packages.buildPythonApplication {
  pname = "cmpgpx";
  version = "0-unstable-2015-06-05";
  format = "other";

  src = fetchFromGitHub {
    owner = "jonblack";
    repo = "cmpgpx";
    rev = "ec3ff781da9b7bcbc2dee44a3bd641cbd5005efe";
    hash = "sha256-iJajSbDDPkBmGKZp0QH03RK9VBMmLHWvHViojlQJArs=";
  };

  dependencies = with python3Packages; [
    cairocffi
    geotiler
    gpxpy
    numpy
  ];

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    install -Dm644 geo.py gfx.py -t $out/lib/${python3Packages.python.libPrefix}/site-packages
    install -Dm755 cmpgpx.py $out/bin/cmpgpx
    install -Dm755 dist.py $out/bin/dist
  '';

  meta = {
    description = "Show the differences between GPX files";
    homepage = "https://github.com/jonblack/cmpgpx";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "cmpgpx";
  };
}
