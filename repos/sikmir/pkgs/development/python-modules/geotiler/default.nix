{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "geotiler";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "wrobell";
    repo = "geotiler";
    rev = "geotiler-${version}";
    hash = "sha256-OEz7LhkmAkfGNTSu5aUeMsNaUa4Whzg9520n3ILbDKw=";
  };

  postPatch = ''
    sed -i '/setuptools_git/d' setup.py
  '';

  propagatedBuildInputs = with python3Packages; [ aiohttp cytoolz numpy pillow ];

  checkInputs = with python3Packages; [ pytestCheckHook pytest-cov ];

  postInstall = ''
    cp -r geotiler/source $out/lib/${python3Packages.python.libPrefix}/site-packages/geotiler
  '';

  meta = with lib; {
    description = "GeoTiler is a library to create map using tiles from a map provider";
    homepage = "https://wrobell.dcmod.org/geotiler";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
