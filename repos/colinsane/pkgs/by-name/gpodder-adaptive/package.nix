{
  fetchFromGitHub,
  fetchpatch,
  gitUpdater,
  gpodder,
  libhandy,
}:

let
self = gpodder.overridePythonAttrs (upstream: rec {
  pname = "gpodder-adaptive";
  version = "3.11.4+1";
  src = fetchFromGitHub {
    owner = "gpodder";
    repo = "gpodder";
    rev = "adaptive/${version}";
    hash = "sha256-ydbFwX44Pg2p4HknEQ7B74ZpRVILxxBxhjWeTKY9odc=";
  };

  patches = (upstream.patches or []) ++ [
    (fetchpatch {
      # necessary for Python 3.12 compatibility; remove when upgrading past 3.11.4.
      # TODO: merge into nixpkgs' gpodder expression
      name = "Replace the removed imp module with importlib";
      url = "https://github.com/gpodder/gpodder/commit/dd9b594d24a541c0f1d3b096e47b6d7f1c11ca7e.patch";
      hash = "sha256-jAe3onmuPdwBhspWHhMf2Gy1hj5GiGoZjkpLAAy/ZIE=";
    })
  ];

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

  postFixup = ''
    substituteInPlace $out/share/applications/gpodder-url-handler.desktop \
      --replace-fail 'Exec=/bin/gpodder' 'Exec=gpodder'
  '';

  buildInputs = upstream.buildInputs ++ [
    libhandy
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "adaptive/";
  };
});
in self // {
  meta = self.meta // {
    # ensure nix thinks the canonical position of this derivation is inside my own repo,
    # not upstream nixpkgs repo. this ensures that the updateScript can patch the version/hash
    # of the right file. meta.position gets overwritten if set in overrideAttrs, hence this
    # manual `//` hack
    position = let
      pos = builtins.unsafeGetAttrPos "src" self;
    in "${pos.file}:${builtins.toString pos.line}";
  };
}
