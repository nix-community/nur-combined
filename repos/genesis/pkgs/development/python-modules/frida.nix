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
  version = "12.11.18";
  disabled = !isPy38;

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "194ilih5fyk8h5nx2a4rqh3njlgwjylwi5rx7zd3lg60ii88lrzh";
  };

  # "~/frida-{}-py{}.{}-{}.egg".format(frida_version, python_version[0], python_version[1], os_version))
  egg =  fetchurl {
    url = "https://files.pythonhosted.org/packages/33/0d/d45e34f8f4333b30bf1f9fcc95b23fd16a03c90477b8018fbb9f9e9a3272/${pname}-${version}-py3.8-linux-x86_64.egg";
    sha256 = "583ac3d9e0831a03435756dcb67bee092f6ec92ad5756d40dbc0683755d6590f";
  };

  postPatch = ''
   # sed -i "s/'build_ext': FridaPrebuiltExt//" setup.py
   export HOME=.
   cp ${egg} ./frida-12.11.18-py3.8-linux-x86_64.egg
  '';

  #doCheck = false;

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
  };
}
