{ stdenv
, buildPythonPackage
, fetchPypi
, fetchurl
, isPy38
, python3
}:

let
  pname = "frida";
  version = "14.0.5";
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
      sha256 = "1hp84qp7fk31cmqacabv0d1x79mlbdr1qqs5l1gbljs4zdhhh9ss";
    };
  };

in
buildPythonPackage rec {

  inherit pname version;
  disabled = !isPy38;

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "38e62660788316a8dcd83e3ddd4996c47d271c2689158d35e7b35446a6a1e964";
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
