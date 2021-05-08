# This is largely taken from the NUR package of genesis, see
# https://github.com/nix-community/nur-combined/blob/master/repos/genesis/pkgs/frida-tools/default.nix.
{ lib
, stdenv
, fetchurl
, python3
}:

let
  pname = "frida";
  version = "14.2.18";
  pythonVersion = "38";

  # TODO: Find a way to use fetchPypi.
  # I guess we should add egg support to pkgs/development/interpreters/python/fetchpypi.nix
  # "~/frida-{}-py{}.{}-{}.egg".format(frida_version, python_version[0], python_version[1], os_version))
  eggs =
    let
      #inherit version pname;
      extension = "egg";
      # ${pname}-${version}.${extension}
      base = "https://files.pythonhosted.org/packages/${python3.pythonVersion}/${builtins.substring 0 1 pname}/${pname}";
    in
      {
        # add your system support here
        x86_64-linux = fetchurl {
          url = "${base}/${pname}-${version}-py${python3.pythonVersion}-linux-x86_64.egg";
          sha256 = "1qqj3wfrp0d4pzhg5qqrfbkigydpan49c1y003mk8jl5020k8krn";
        };
      };

in
python3.pkgs.buildPythonPackage rec {

  inherit pname version;
  disabled = !python3.pkgs.isPy38;

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-8OQLiy7+wypUDCWbkj7mWnOmCFwfMNE5rfAchZq69Ho=";
  };

  egg = eggs.${stdenv.hostPlatform.system}
    or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  postPatch = ''
    # sed -i "s/'build_ext': FridaPrebuiltExt//" setup.py
    export HOME=.
    ln -s ${egg} ./${egg.name}
  '';

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ dschrempf ];
    platforms = [ "x86_64-linux" ];
  };
}
