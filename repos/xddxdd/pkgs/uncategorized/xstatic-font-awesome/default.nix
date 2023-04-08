{
  lib,
  sources,
  python3Packages,
  ...
} @ args:
with python3Packages;
  buildPythonPackage rec {
    inherit (sources.xstatic-font-awesome) pname version src;

    meta = with lib; {
      description = "Font Awesome packaged for setuptools (easy_install) / pip.";
      homepage = "https://github.com/FortAwesome/Font-Awesome";
      license = with licenses; [ofl];
    };
  }
