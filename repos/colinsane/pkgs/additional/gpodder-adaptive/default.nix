{ gpodder
, fetchFromGitHub
, libhandy
}:
gpodder.overridePythonAttrs (upstream: rec {
  pname = "gpodder-adaptive";
  version = "3.11.1+1";
  src = fetchFromGitHub {
    owner = "gpodder";
    repo = "gpodder";
    rev = "adaptive/${version}";
    hash = "sha256-pn5sh8CLV2Civ26PL3rrkkUdoobu7SIHXmWKCZucBhw=";
  };

  # nixpkgs `gpodder` uses the `format = "other"` Makefile build flow.
  # upstream specifies a Makefile, and it's just `setup.py` calls plus a few other deps.
  # however, it calls the build Python, which breaks for cross compilation.
  # nixpkgs knows how to cross-compile setuptools formats, so use that and only mimic the
  # parts of the Makefile that aren't part of that.
  # TODO: upstream this into main nixpkgs `gpodder` package.
  format = "setuptools";
  preBuild = ''
    make \
      "PREFIX=$(out)" \
      "share/applications/gpodder-url-handler.desktop" \
      "share/applications/gpodder.desktop" \
      "share/dbus-1/services/org.gpodder.service"
  '';

  buildInputs = upstream.buildInputs ++ [
    libhandy
  ];
})
