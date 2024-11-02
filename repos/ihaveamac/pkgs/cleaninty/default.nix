{ lib, fetchpatch, fetchFromGitHub, buildPythonApplication, cryptography, pycurl, defusedxml }:

buildPythonApplication rec {
  pname = "cleaninty";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "luigoalma";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-QVttOy3WPFZXvbNaJUhFSsEWwPDZgkGuDBR7zxlS+w8=";
  };

  propagatedBuildInputs = [ 
    cryptography
    # https://github.com/NixOS/nixpkgs/pull/351043
    # https://nixpk.gs/pr-tracker.html?pr=351043
    ( pycurl.overrideAttrs (final: prev: {
      patches = [
        # Don't use -flat_namespace on macOS
        # https://github.com/pycurl/pycurl/pull/855 remove on next update
        (fetchpatch {
          name = "no_flat_namespace.patch";
          url = "https://github.com/pycurl/pycurl/commit/7deb85e24981e23258ea411dcc79ca9b527a297d.patch";
          hash = "sha256-tk0PQy3cHyXxFnoVYNQV+KD/07i7AUYHNJnrw6H8tHk=";
        })
      ];
    }) )
    defusedxml
  ];

  meta = with lib; {
    description = "Perform some Nintendo console client to server operations";
    homepage = "https://github.com/luigoalma/cleaninty";
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "cleaninty";
  };
}
