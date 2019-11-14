{ stdenv, fetchurl, python3Packages, cmake, python3 }:

let
  pythonPackages = python3Packages;
in

pythonPackages.buildPythonApplication rec {
  pname = "obitools3";
  version = "3.0.0-beta1";

  src = fetchurl {
    url = "https://git.metabarcoding.org/obitools/${pname}/repository/v${version}/archive.tar.gz";
    sha256 = "135pic5h3vvs8ls3npd7wfwl4y0a0qxm1f2z7ya09d9qbw3zw3kq";
  };

  preBuild = ''
    substituteInPlace src/CMakeLists.txt --replace \$'{PYTHONLIB}' "$out/lib/${python3.libPrefix}/site-packages";
    export NIX_CFLAGS_COMPILE="-L $out/lib/${python3.libPrefix}/site-packages $NIX_CFLAGS_COMPILE"
  '';

  postInstall = "cp obi_completion_script.sh $out/bin";

  disabled = !pythonPackages.isPy3k;

  nativeBuildInputs = [ pythonPackages.cython cmake ];

  dontConfigure = true;

  doCheck = true;

  meta = with stdenv.lib ; {
    description = "Management of analyses and data in DNA metabarcoding";
    homepage = "https://git.metabarcoding.org/obitools/obitools3";
    license = licenses.cecill20;
    maintainers = [ maintainers.bzizou ];
    platforms = platforms.all;
  };
}
