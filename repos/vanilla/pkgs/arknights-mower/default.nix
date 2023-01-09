{ python39Packages, fetchgit, callPackage, lib, stdenv, ... }:
let onnxruntime = callPackage ./onnxruntime-py39.nix { }; in
let imagehash = callPackage ./imagehash.nix { }; in
let opencv_python = callPackage ./opencv_python.nix { }; in
python39Packages.buildPythonPackage rec {
  pname = "arknights-mower";
  version = "1.3.9";

  src = fetchgit {
    url = "https://github.com/Konano/${pname}";
    rev = "v${version}";
    hash = "sha256-7OZV2n2NSu785AAgzpsaoJuDmad2N7+f/fYqNnUx0L8=";
  };

  buildInputs = [ python39Packages.setuptools ];
  propagatedBuildInputs = with python39Packages; [ matplotlib ]
    ++ [ onnxruntime ] ++ (with python39Packages;
    [ scikit-learn pyclipper shapely colorlog scikitimage imagehash ])
    ++ [ imagehash opencv_python ];

  # https://stackoverflow.com/questions/14463277/how-to-disable-python-warnings
  postFixup = "wrapProgram $out/bin/${pname} --set PYTHONWARNINGS ignore";

  doCheck = # Compiling in QEMU cannot pass.
    if stdenv.isAarch64 then false
    else true;

  meta = with lib; {
    description = "《明日方舟》长草助手";
    homepage = "https://github.com/Konano/${pname}";
    license = licenses.mit;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
