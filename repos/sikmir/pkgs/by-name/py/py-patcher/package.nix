{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "py-patcher";
  version = "0-unstable-2024-12-13";
  format = "other";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "py_patcher";
    rev = "da55892a90eefaabffcf1eae2d6fd8a15ae26e15";
    hash = "sha256-po4Vg1j6Q65b8+syStegordTndSxJXYXNPigOTpjaUY=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    install -Dm755 patcher.py $out/bin/patcher
    install -Dm644 patches.txt -t $out/share/py-patcher
  '';

  meta = {
    description = "A python version of Garmin firmware patcher";
    homepage = "https://github.com/slazav/py_patcher";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
