extension:
{ lib, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
} @ args:

rustPlatform.buildRustPackage (let super = {
  pname = "hacksaw";
  # version = ...;

  srcFunction = fetchFromGitHub;
  src = {
    owner = "neXromancers";
    repo = "hacksaw";
    rev = "v${self.version}";
    # sha256 = ...;
  };

  # cargoSha256 = ...;

  nativeBuildInputs = [
    buildPackages.pkgconfig
    buildPackages.python3
  ];
  buildInputs = [ libX11 libXrandr ];

  meta = with lib; {
    description = "Lets you select areas of your screen (on X11)";
    homepage = "https://github.com/neXromancers/hacksaw";
    license = licenses.mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}; self = super // extension args self super;
in builtins.removeAttrs self [ "srcFunction" ] // {
  src = self.srcFunction self.src;
})
