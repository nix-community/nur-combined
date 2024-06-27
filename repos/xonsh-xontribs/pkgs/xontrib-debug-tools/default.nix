{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-debug-tools";
  version = "0.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-debug-tools";
    rev = "b2d27820b5d377e0bb881632034e92ffac8edc01";
    sha256 = "sha256-Z8AXKk94NxmF5rO2OMZzNX0GIP/Vj+mOtYUaifRX1cw=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  meta = {
    homepage = "https://github.com/xonsh/xontrib-debug-tools";
    license = ''
      MIT License  Copyright (c) 2023, xontrib-debug-tools  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    '';
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) Debug tools for xonsh shell. ";
  };
}
