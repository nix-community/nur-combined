{ stdenv, lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "dyndnsc";
  version = "0.6.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "a2a930c30b095735f2745d9db3197e598a24e73da457ccb82bda10ae49e1d59a";
  };

  nativeBuildInputs = with python3Packages; [ pytestrunner ];
  propagatedBuildInputs = with python3Packages; [
    daemonocle
    dnspython
    json-logging
    netifaces
    requests
    setuptools
  ];
  checkInputs = with python3Packages; [ bottle pytest ];

  postPatch = ''
    substituteInPlace setup.py --replace "bottle==" "bottle>="
  '';

  checkPhase =
    let
      inherit (lib) concatStringsSep optional;
      # dnswanip connects to an external server to discover the
      # machine's IP address.
      #
      # The tests that spawn a server using Bottle cannot be run on
      # macOS or Windows as the default multiprocessing start method
      # on those platforms is 'spawn', which requires the code to be
      # run to be picklable, which this code isn't.
      # Additionaly, other start methods are unsafe and prone to failure
      # on macOS; see https://bugs.python.org/issue33725.
      testsToDisable = [ "dnswanip" ]
        ++ optional stdenv.isDarwin "BottleServer";
    in
    ''
      runHook preCheck

      python -m pytest -k '${concatStringsSep " and " (map (test: "not ${test}") testsToDisable)}'

      runHook postCheck
    '';
  # Allow tests involving localhost on macOS.
  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "Dynamic DNS update client with support for multiple protocols";
    longDescription = ''
      Dyndnsc is a command line client for sending updates to Dynamic
      DNS (DDNS, DynDNS) services.  It supports multiple protocols and
      services, and it has native support for IPv6.  The configuration
      file allows using foreign, but compatible services.  Dyndnsc
      ships many different IP detection mechanisms, support for
      configuring multiple services in one place and it has a daemon
      mode for running unattended.  It has a plugin system to provide
      external notification services.
    '';
    homepage = "https://github.com/infothrill/python-dyndnsc";
    license = licenses.mit;
    platforms = platforms.unix;
    hydraPlatforms = platforms.none;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
