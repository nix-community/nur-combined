{ lib
, fetchFromGitHub
, buildPythonApplication
, distutils_extra
, intltool
}:
let 
  pyModuleDeps = [
    distutils_extra
  ];
  version = "20.04.1";
in
buildPythonApplication {

  pname = "gufw";
  inherit version;

  src = fetchFromGitHub {
    owner = "costales";
    repo = "gufw";
    rev = version;
    sha256 = "16kl5gp5mqdiqkxfm6bjb0s88ik930q3pz8q6w021gxqbam2vr0w";
  };

  patches = [ ./fix-bash-error.patch ];

  postPatch = ''
    patchShebangs bin/gufw
  '';
  
  nativeBuildInputs = [ intltool ];
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps ++ [ intltool ];

  doCheck = false;
  
  meta = with lib; {
    description = "Graphical user interface for Ubuntu's Uncomplicated Firewall";
    license = licenses.gpl3;
    homepage = "https://github.com/costales/gufw";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = with platforms; linux;
  };
}
