{ stdenv
, python3
, buildPythonPackage
, keystone
, python2
}:

buildPythonPackage rec {
  inherit (keystone) pname src version;

  buildInputs = [ keystone ];

  preBuild = ''
    cd bindings
    ${python2.interpreter} const_generator.py python
    cd python
  '';

  postInstall = ''
    ln -s ${stdenv.lib.getLib keystone}/lib/*${stdenv.hostPlatform.extensions.sharedLibrary} \
      $out/${python3.sitePackages}/keystone
  '';

  preCheck = ''
    export LD_LIBRARY_PATH=${stdenv.lib.getLib keystone}/lib/
  '';

  meta = with stdenv.lib; {
    inherit (keystone.meta) description homepage license;
  };
}
