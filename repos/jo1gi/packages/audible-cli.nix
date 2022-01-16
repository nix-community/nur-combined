{ pkgs, stdenv, lib, fetchFromGitHub }:
with pkgs.python3Packages;

let
  audible = buildPythonPackage rec {
    pname = "audible";
    version = "0.6.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "SdQ5mk/2YZ2npCGYvqk+5tKWb7XJjAELeMOfwBHvWyU=";
    };

    propagatedBuildInputs = [ pbkdf2 pillow httpxlib beautifulsoup4 rsa pyaes ];

    doCheck = false;
  };

  httpxlib = buildPythonPackage rec {
    pname = "httpx";
    version = "0.20.0";
    disabled = pythonOlder "3.6";

    src = fetchFromGitHub {
      owner = "encode";
      repo = pname;
      rev = version;
      sha256 = "sha256-j9dX2N29vRdi7RAkCiWqec3ztiUW2u+Bi44QUucUqs8=";
    };

    propagatedBuildInputs = [
      brotlicffi
      certifi
      charset-normalizer
      h2
      httpcore
      rfc3986
      sniffio
    ];

    checkInputs = [
      pytestCheckHook
      pytest-asyncio
      pytest-trio
      trustme
      typing-extensions
      uvicorn
    ];

    pythonImportsCheck = [ "httpx" ];

  # testsuite wants to find installed packages for testing entrypoint
  preCheck = ''
    export PYTHONPATH=$out/${python.sitePackages}:$PYTHONPATH
  '';

  disabledTests = [
    # httpcore.ConnectError: [Errno 101] Network is unreachable
    "test_connect_timeout"
    # httpcore.ConnectError: [Errno -2] Name or service not known
    "test_async_proxy_close"
    "test_sync_proxy_close"
    # sensitive to charset_normalizer output
    "iso-8859-1"
    "test_response_no_charset_with_iso_8859_1_content"
  ];

  disabledTestPaths = [
    "tests/test_main.py"
  ];

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "The next generation HTTP client";
    homepage = "https://github.com/encode/httpx";
    license = licenses.bsd3;
    maintainers = with maintainers; [ costrouc fab ];
  };
};
in

  buildPythonApplication rec {
    pname = "audible-cli";
    version = "0.0.6";

    src = fetchPypi {
      inherit pname version;
      sha256 = "IIKqqj8l5pU880rZufFW++LCi8oJFn71RzXHc51a2jM=";
    };

    propagatedBuildInputs = [ toml click audible aiofiles tqdm tabulate httpxlib setuptools ];

    doCheck = false;

    meta = with lib; {
      description = "A command line interface for audible package. With the cli you can download your Audible books, cover, chapter files.";
      homepage = "https://github.com/mkb79/audible-cli";
      license = licenses.agpl3;
      maintainers = [ maintainers.jo1gi ];
      platforms = platforms.all;
    };
  }
