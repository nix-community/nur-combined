{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "CJKwrap";
  version = "2.2";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-osfS5Seg6JhlrC5uc/GYuCm4ccgm807rTvsJZp4ewKw=";
  };

  meta = with lib; {
    description = "A library for wrapping and filling UTF-8 CJK text";
    homepage = "https://f.gallai.re/cjkwrap";
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
