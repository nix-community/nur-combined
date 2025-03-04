{ python3Packages
, pkgs
, generated
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pyproject = true;

  inherit (generated) pname version src;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    pkgs.fava
    pkgs.beancount
    pkgs.beanquery
    pyyaml
  ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="0.1.0"
  '';

  meta = {
    description = "Custom Dashboards for Beancount in Fava";
    homepage = "https://github.com/andreasgerstmayr/fava-dashboards";
    license = lib.licenses.gpl2;
  };
}

