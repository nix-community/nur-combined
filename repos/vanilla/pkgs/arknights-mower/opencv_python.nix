{ python3Packages, fetchPypi, autoPatchelfHook, xlibs, glib, libglvnd, ... }:
python3Packages.buildPythonPackage rec {
  pname = "opencv_python";
  version = "4.5.5.62";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    hash = "sha256-EwzHXVaymqPF3otqxDgkLdJXS6bqqLzN/9z9a3hjL38=";

    dist = "cp36";
    python = "cp36";

    abi = "abi3";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
  };

  propagatedBuildInputs = with python3Packages; [ numpy ];

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ xlibs.libX11 glib xlibs.libSM libglvnd ];

  # ELF load command address/offset not properly aligned
  dontStrip = true;
}
