{ python39Packages, fetchPypi, autoPatchelfHook, xorg, glib, libglvnd, stdenv, ... }:
python39Packages.buildPythonPackage rec {
  pname = "opencv_python";
  version = "4.5.5.62";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;

    hash =
      if stdenv.isAarch64 then "sha256-cf3EnfQSsQLZfxSScyEwkEPHnEo1gszh3IAzcP+cOcA="
      else "sha256-EwzHXVaymqPF3otqxDgkLdJXS6bqqLzN/9z9a3hjL38=";

    dist = "cp36";
    python = "cp36";

    abi = "abi3";

    platform =
      if stdenv.isAarch64 then "manylinux_2_17_aarch64.manylinux2014_aarch64"
      else "manylinux_2_17_x86_64.manylinux2014_x86_64";
  };

  propagatedBuildInputs = with python39Packages; [ numpy ];

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ xorg.libX11 glib xorg.libSM libglvnd ];

  # ELF load command address/offset not properly aligned
  dontStrip = true;
}
