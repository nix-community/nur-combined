# This is largely taken from the NUR package of genesis, see
# https://github.com/nix-community/nur-combined/blob/master/repos/genesis/pkgs/frida-tools/default.nix.
{ lib
, stdenv
, fetchurl
, python3
}:

let
  pname = "frida-python";
  version = "15.0.13";
  namePypi = "frida";
  pythonVersion = "38";
  base = "https://files.pythonhosted.org/packages/${python3.pythonVersion}/${builtins.substring 0 1 namePypi}/${namePypi}";
  eggs = {
    x86_64-linux = fetchurl {
      url = "${base}/${namePypi}-${version}-py${python3.pythonVersion}-linux-x86_64.egg";
      sha256 = "sha256-fg7tEY1MmVEr/TC3eiD9tGcj7P+o872KRd5sAXFwnRk=";
    };
  };
in
python3.pkgs.buildPythonPackage rec {
  inherit pname version;
  # TODO: Nixpkgs has moved to Python 3.9 by default.
  disabled = !python3.pkgs.isPy38;

  src = python3.pkgs.fetchPypi {
    pname = namePypi;
    inherit version;
    sha256 = "sha256-wOra4E4db9HqAy3VGWdksHcN85rvaEqbv1k1kRtqC1Q=";
  };

  egg = eggs.${stdenv.hostPlatform.system}
    or (throw "unsupported system: ${stdenv.hostPlatform.system}");

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
