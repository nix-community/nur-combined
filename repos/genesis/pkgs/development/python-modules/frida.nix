{ stdenv
, buildPythonPackage
, fetchPypi
, fetchurl
, isPy38
, python3
}:

let
  pname = "frida";
  version = "14.0.6";
  pythonVersion = "38";

  # TODO : find a way to use fetchPypi
  # i guess we should add egg support to pkgs/development/interpreters/python/fetchpypi.nix
  # "~/frida-{}-py{}.{}-{}.egg".format(frida_version, python_version[0], python_version[1], os_version))
  eggs = let
    #inherit version pname;
    extension = "egg";
    # ${pname}-${version}.${extension}
    base = "https://files.pythonhosted.org/packages/${python3.pythonVersion}/${builtins.substring 0 1 pname}/${pname}";
  in {
    # add your system support here
    x86_64-linux = fetchurl {
      url = "${base}/${pname}-${version}-py${python3.pythonVersion}-linux-x86_64.egg";
      sha256 = "137svmdj6aaa5waxhhz5m41gv6rfqc87ycr3g7ck8gimqvqzc1xz";
    };
  };

in
buildPythonPackage rec {

  inherit pname version;
  disabled = !isPy38;

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "1p04acf4q1a9livsl531xxwd5m92klvcqjplzg6hihzgnmrn38af";
  };

  egg = eggs.${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  postPatch = ''
   # sed -i "s/'build_ext': FridaPrebuiltExt//" setup.py
   export HOME=.
   ln -s ${egg} ./${egg.name}
  '';

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
    maintainers = with maintainers; [ genesis ];
    platforms = [ "x86_64-linux" ];
  };
}
