{ stdenv
, buildPythonPackage
, fetchPypi
, fetchurl
, isPy38
, python3
}:

let
  pythonVersion = "38";
in
buildPythonPackage rec {
  pname = "frida";
  version = "14.0.1";
  disabled = !isPy38;

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "0830f966325334d590d4b37842d8f0816d0996aa47a2c7cc60c2aeb008271ee5";
  };

  # TODO : find a way to use fetchPypi
  # "~/frida-{}-py{}.{}-{}.egg".format(frida_version, python_version[0], python_version[1], os_version))
  egg =  fetchurl {
    #inherit version pname;
    #extension = "egg";
    url = "https://files.pythonhosted.org/packages/0d/d5/d4508955cc51f9ae86b3c7a177077b8122aa6b34c5879ca21e3be2653c23/${pname}-${version}-py${python3.pythonVersion}-linux-x86_64.egg";
    sha256 = "1z0lrqj1aja23g0xicvhgdf5blkf1f43547g41v2nq9m4l84xg6g";
  };

  postPatch = ''
   # sed -i "s/'build_ext': FridaPrebuiltExt//" setup.py
   export HOME=.
   cp ${egg} ./${egg.name}
  '';

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
  };
}
