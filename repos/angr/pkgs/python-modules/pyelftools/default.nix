/*
* DISCLAIMER
* `angr/cle` is dependent on features that have neither been merged, nor not yet packaged in `pyelftools`;
* As I am writing this, the latest version of `pyelftools` is 0.26, so it is likely than this expression
* won't be necessary once 0.27 will be out.
*/

{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, patchelf
, pkgs
, python
}:

buildPythonPackage rec {
  pname = "pyelftools";
  version = "unstable-2020-06-03";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "ltfish";
    repo = pname;
    rev = "609310dd46a78e98b39461ac1c23d4b2011a213b";
    sha256 = "12zbvxyziad3qqjfvfv40azhdk8jkyc7y4b78immlrgha8sjrl2g";
  };

  checkInputs = [ patchelf ];

  checkPhase = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" test/external_tools/readelf
    ${python.interpreter} test/all_tests.py
  '';

  meta = with pkgs.lib; {
    description = "A library for analyzing ELF files and DWARF debugging information";
    homepage = "https://github.com/eliben/pyelftools";
    license = licenses.publicDomain;
    maintainers = [ maintainers.pamplemousse ];
  };
}
