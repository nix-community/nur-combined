{ fetchPypi
, lib
, python3Packages
}:

# Copy of https://github.com/NixOS/nixpkgs/pull/288070, while it gets merged
python3Packages.buildPythonPackage rec {
  pname = "requests-gssapi";
  version = "1.2.3";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IHhFCJgUAfcVPJM+7QlTOJM6QIGNplolnb8tgNzLFQ4=";
  };

  propagatedBuildInputs = with python3Packages; [
    gssapi
    requests
  ];
  pythonImportCheck = [ "requests_gssapi" ];

  meta = with lib; {
    description = "A GSSAPI authentication handler for python-requests";
    homepage = "https://github.com/pythongssapi/requests-gssapi";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.isc ];
    platforms = platforms.all;
  };
}

