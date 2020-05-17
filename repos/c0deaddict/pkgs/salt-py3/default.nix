{
  stdenv, python3Packages, openssl,

  # Many Salt modules require various Python modules to be installed,
  # passing them in this array enables Salt to find them.
  extraInputs ? []
}:

python3Packages.buildPythonApplication rec {
  pname = "salt";
  version = "2019.2.3";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "06i7h5ymlxz5by8g6l21cjxinc5qk3d67nn8pfdpkhsdzpdyg5vl";
  };

  propagatedBuildInputs = with python3Packages; [
    jinja2
    markupsafe
    msgpack
    pycrypto
    pyyaml_3
    pyzmq
    requests
    tornado_4
  ] ++ extraInputs;

  patches = [ <nixpkgs/pkgs/tools/admin/salt/fix-libcrypto-loading.patch> ];

  postPatch = ''
    substituteInPlace "salt/utils/rsax931.py" \
      --subst-var-by "libcrypto" "${openssl.out}/lib/libcrypto.so"
  '';

  # The tests fail due to socket path length limits at the very least;
  # possibly there are more issues but I didn't leave the test suite running
  # as is it rather long.
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://saltstack.com/";
    description = "Portable, distributed, remote execution and configuration management system";
    maintainers = with maintainers; [ aneeshusa ];
    license = licenses.asl20;
  };
}
