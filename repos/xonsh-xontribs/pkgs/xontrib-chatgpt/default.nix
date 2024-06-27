{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-chatgpt";
  version = "0.2.3";
  src = pkgs.fetchFromGitHub {
    owner = "drmikecrowe";
    repo = "xontrib-chatgpt";
    rev = "a2f4957504188a415ed0679b1a527c15f630b97c";
    sha256 = "sha256-liuG5m/9YdOxM8bSMv1J8aOI2F5Q4SKN5TGVOLEIXu4=";
  };

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
    openai
  ];

  propagatedBuildInputs = [
    pkgs.python3Packages.openai
  ];

  meta = {
    homepage = "https://github.com/jpal91/xontrib-chatgpt";
    license = ''
      MIT License  Copyright (c) 2023, Justin Pallansch  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    '';
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) Gives the ability to use ChatGPT directly from the command line";
  };
}
