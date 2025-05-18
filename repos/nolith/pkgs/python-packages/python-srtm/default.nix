{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "python-srtm";
  version = "0.6.0";
  format = "wheel";

  src = fetchPypi {
    inherit version format;
    pname = "python_srtm";
    hash = "sha256-J+WEq08MohA7DWr/UuPkzHtw2e0nh/9MDHAlMpseEf8=";
    dist = "py3";
    python = "py3";
    platform = "any";
  };

  meta = with lib; {
    changelog = "https://github.com/pytest-dev/pytest/releases/tag/${version}";
    description = "Python API for reading NASA's SRTM `.hgt` or `.hgt.zip` altitude files";
    homepage = "https://github.com/adamcharnock/python-srtm";
    license = licenses.mit;
  };
}
