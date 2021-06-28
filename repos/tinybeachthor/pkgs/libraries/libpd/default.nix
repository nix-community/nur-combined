{ stdenv
, lib
, fetchFromGitHub
, autoPatchelfHook
, multiInstances ? true
}:

stdenv.mkDerivation rec {
  pname = "libpd";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "libpd";
    repo = pname;
    rev = version;
    sha256 = "sha256-04pSzNGum65Y+IXG6THroWXEAIwVXs7hGTY5H1MLj60=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildPhase = ''
    make libpd MULTI=${lib.boolToString multiInstances}

    mkdir $out
    mkdir $out/lib
    cp libs/libpd.so $out/lib/
  '';

  dontInstall = true;

  meta = with lib; {
    description = "Pure Data embeddable audio synthesis library";
    homepage = "https://github.com/libpd/libpd";
    license = licenses.bsd3;
    platforms = with platforms; linux;
  };
}
