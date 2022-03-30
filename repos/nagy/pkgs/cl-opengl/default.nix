{ lispPackages, fetchFromGitHub, libglvnd, ... }:

lispPackages.buildLispPackage {

  baseName = "cl-opengl";
  version = "unstable-2019-11-22";

  buildSystems = [ ];

  description = "A set of CFFI bindings to the OpenGL, GLU and GLUT APIs";

  deps = [ lispPackages.float-features ];

  propagatedBuildInputs = [ libglvnd ];

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "cl-opengl";
    rev = "e2d83e0977b7e7ac3f3d348d8ccc7ccd04e74d59";
    sha256 = "0mhqmll09f079pnd6mgswz9nvr6h5n27d4q7zpmm2igf1v460id7";
  };
}
