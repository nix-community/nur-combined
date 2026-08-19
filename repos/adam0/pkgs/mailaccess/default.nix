{
  # keep-sorted start
  fetchPypi,
  lib,
  python3Packages,
  # keep-sorted end
}: let
  holehe = python3Packages.buildPythonPackage rec {
    pname = "holehe";
    version = "1.61";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-GgLnwQO5q8tIXrCqyjbZUKxr/07AAdZENizEZzmRazs=";
    };

    build-system = [python3Packages.setuptools];

    dependencies = with python3Packages; [
      # keep-sorted start
      beautifulsoup4
      colorama
      httpx
      termcolor
      tqdm
      trio
      # keep-sorted end
    ];

    doCheck = false;
    pythonImportsCheck = ["holehe"];
    pythonRemoveDeps = ["bs4"];
  };

  user-scanner = python3Packages.buildPythonPackage rec {
    pname = "user-scanner";
    version = "1.5.0";
    pyproject = true;

    src = fetchPypi {
      pname = "user_scanner";
      inherit version;
      hash = "sha256-RjNrdGgAazt0X6SxT67+1CouCOZ+hhkJ09fnD7Vo4M4=";
    };

    build-system = [python3Packages.flit-core];

    dependencies = with python3Packages; [
      # keep-sorted start
      colorama
      curl-cffi
      httpx
      rich
      socksio
      # keep-sorted end
    ];

    doCheck = false;
    pythonImportsCheck = ["user_scanner"];
  };
in
  python3Packages.buildPythonApplication rec {
    pname = "mailaccess";
    version = "0.14.3";
    format = "wheel";

    src = fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-vaIwzgnPGJ05Kn70Pms1VNXerTRiEJ3MPaYqTJ8aWuc=";
    };

    postInstall = ''
      substituteInPlace "$out/${python3Packages.python.sitePackages}/backend/main.py" \
        --replace-fail \
          'Path(__file__).parent.parent / "maltego" / "MailAccess.mtz"' \
          'Path.home() / ".mailaccess" / "maltego" / "MailAccess.mtz"'
    '';

    dependencies = with python3Packages; [
      # keep-sorted start
      aiosqlite
      asyncpg
      curl-cffi
      dnspython
      fastapi
      holehe
      httpx
      imagehash
      pillow
      pydantic
      pydantic-settings
      python-dotenv
      python-whois
      pyyaml
      rapidfuzz
      rich
      sqlalchemy
      stix2
      typer
      unidecode
      user-scanner
      uvicorn
      websockets
      # keep-sorted end
    ];

    doCheck = false;
    pythonImportsCheck = [
      "backend"
      "cli"
    ];

    meta = {
      # keep-sorted start
      description = "Open-source OSINT email intelligence tool";
      homepage = "https://github.com/KatrielMoses/MailAccess";
      license = lib.licenses.mit;
      mainProgram = "mailaccess";
      platforms = lib.platforms.unix;
      # keep-sorted end
    };
  }
