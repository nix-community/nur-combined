{ stdenv, fetchurl, python3Packages, cmake, python3, bash }:

let
  pythonPackages = python3Packages;
in

pythonPackages.buildPythonApplication rec {
  pname = "obitools3";
  version = "3.0.0-beta11";

  src = fetchurl {
    url = "https://git.metabarcoding.org/obitools/${pname}/repository/v${version}/archive.tar.gz";
    sha256 = "99f9a0713e9bb0013fc773fd920173a05628c02f04faaf1a9e031d85149833ab";
  };

  preBuild = ''
    substituteInPlace python/obitools3/dms/dms.pyx --replace "/bin/bash" "${bash}/bin/bash";
    substituteInPlace python/obitools3/dms/view/view.pyx --replace "/bin/bash" "${bash}/bin/bash";
    substituteInPlace src/CMakeLists.txt --replace \$'{PYTHONLIB}' "$out/lib/${python3.libPrefix}/site-packages";
    export NIX_CFLAGS_COMPILE="-L $out/lib/${python3.libPrefix}/site-packages $NIX_CFLAGS_COMPILE"
  '';

  patches = [ ./completion_bugfix.patch ];

  postInstall = ''
    patchShebangs ./obi_completion_script.sh;
    cp obi_completion_script.sh "$out/bin";
  '';

  disabled = !pythonPackages.isPy3k;

  nativeBuildInputs = [ pythonPackages.cython cmake ];

  dontConfigure = true;

  doCheck = true;

  enableParallelBuilding = true;

  meta = with stdenv.lib ; {
    description = "Management of analyses and data in DNA metabarcoding";
    homepage = "https://git.metabarcoding.org/obitools/obitools3";
    license = licenses.cecill20;
    maintainers = [ maintainers.bzizou ];
    platforms = platforms.all;
  };
}
