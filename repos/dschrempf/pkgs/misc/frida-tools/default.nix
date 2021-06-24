# This is largely taken from the NUR package of genesis, see
# https://github.com/nix-community/nur-combined/blob/master/repos/genesis/pkgs/frida-tools/default.nix.
{ lib, python3, frida-python, fetchFromGitHub }:

python3.pkgs.buildPythonApplication rec {
  pname = "frida-tools";
  version = "9.2.5";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-NUc2Jm+dolhtShqTJ4ht6Jbtl6WQh8NzIlmZ9+HOs3I=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pygments
    prompt_toolkit
    colorama
    frida-python
  ];

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers (client tools)";
    homepage = "https://www.frida.re/";
    maintainers = with maintainers; [ dschrempf ];
    license = licenses.wxWindows;
  };
}
