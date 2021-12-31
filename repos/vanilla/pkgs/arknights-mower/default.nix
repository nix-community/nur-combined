{ python3Packages, fetchgit, callPackage, ... }:
let onnxruntime = callPackage ./onnxruntime-py39.nix { }; in
let imagehash = callPackage ./imagehash.nix { }; in
let opencv_python = callPackage ./opencv_python.nix { }; in
python3Packages.buildPythonPackage rec {
  pname = "arknights-mower";
  version = "1.3.9";

  src = fetchgit {
    url = "https://github.com/Konano/${pname}";
    rev = "v${version}";
    hash = "sha256-7OZV2n2NSu785AAgzpsaoJuDmad2N7+f/fYqNnUx0L8=";
  };

  propagatedBuildInputs = with python3Packages; [ matplotlib ]
    ++ [ onnxruntime ] ++ (with python3Packages;
    [ scikit-learn pyclipper shapely colorlog scikitimage imagehash ])
    ++ [ imagehash opencv_python ];

  # https://stackoverflow.com/questions/14463277/how-to-disable-python-warnings
  postFixup = "wrapProgram $out/bin/${pname} --set PYTHONWARNINGS ignore";
}
