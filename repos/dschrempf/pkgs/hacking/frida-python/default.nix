# This is largely taken from the NUR package of genesis, see
# https://github.com/nix-community/nur-combined/blob/master/repos/genesis/pkgs/frida-tools/default.nix.
{ lib
, stdenv
, fetchurl
, python3
, system
}:

let
  pname = "frida-python";
  version = "15.1.24";
  namePypi = "frida";
  pythonVersion = "38";
  base = "https://files.pythonhosted.org/packages/${python3.pythonVersion}/${builtins.substring 0 1 namePypi}/${namePypi}";
  egg =
    if system == "x86_64-linux"
    then
      fetchurl
        {
          url = "${base}/${namePypi}-${version}-py${python3.pythonVersion}-linux-x86_64.egg";
          sha256 = "sha256-Ze8scGvlaRLvzEER3TyzMw2sqXcJLO54LI0jsyOIuCs=";
        }
    else throw "unsupported system: ${stdenv.hostPlatform.system}";
in
python3.pkgs.buildPythonPackage rec {
  inherit pname version;
  disabled = !python3.pkgs.isPy38;

  src = python3.pkgs.fetchPypi {
    pname = namePypi;
    inherit version;
    sha256 = "sha256-QnPjtB60iaB9/8L+gb3NeqwE+javo1keNpYn5iC4Qg8=";
  };

  postPatch = ''
    # sed -i "s/'build_ext': FridaPrebuiltExt//" setup.py
    export HOME=.
    ln -s ${egg} ./${egg.name}
  '';

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers (Python bindings)";
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ dschrempf ];
    platforms = [ "x86_64-linux" ];
  };
}
