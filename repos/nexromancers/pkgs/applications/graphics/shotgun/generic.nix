extension:
{ lib, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
} @ args:

rustPlatform.buildRustPackage (let super = {
  pname = "shotgun";
  # version = ...;

  srcFunction = fetchFromGitHub;
  src = {
    owner = "neXromancers";
    repo = "shotgun";
    rev = "v${self.version}";
    # sha256 = ...;
  };

  # cargoSha256 = ...;

  nativeBuildInputs = [ buildPackages.pkgconfig ];
  buildInputs = [ libX11 libXrandr ];

  meta = with lib; {
    description = "A minimal screenshot utility for X11";
    homepage = "https://github.com/neXromancers/shotgun";
    license = licenses.mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}; self = super // extension args self super;
in builtins.removeAttrs self [ "srcFunction" ] // {
  src = self.srcFunction self.src;
})
