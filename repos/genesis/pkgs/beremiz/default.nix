{ stdenv, fetchFromBitbucket, matiec 
 , python3, python3Packages }:

 # wxglade (python) http://wxglade.sourceforge.net/
 # optionals : CanFestival modbus BACnet

python3Packages.buildPythonApplication rec {
  version = "unstable-2017-10-20";
  pname = "beremiz";

  src = fetchFromBitbucket {
    owner = "automforge";
    repo = pname;
    rev = "7e31997";
    sha256 = "06fpnb935r0gfalpbxd6h6i9v7gfsri6scc8bnv8d623zxs2n0p6";
  };

  nativeBuildInputs = [  ];
  buildInputs = with python3Packages; [
    python3
    matiec
    twisted
    wxPython40
    #nevow
    numpy
    lxml
    # Pyro4 ( beremiz uses pyro3.16 )
    # zeroconf (only python3)
    cycler
    matplotlib
    autobahn
    u-msgpack-python
    simplejson
    # sslpsk https://github.com/drbild/sslpsk
    # posix_spawn https://github.com/JonathonReinhart/python-posix-spawn ?
    # wamp http://wamp.ws/
    zope_interface
  ];

  doBuild = false;
  #propagatedBuildInputs = [ python3Packages.wxPython ];

  meta = with stdenv.lib;{
    homepage = "https://beremiz.org";
    description = "Open Source framework for automation";
    license = licenses.gpl3;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux;
  };
}
