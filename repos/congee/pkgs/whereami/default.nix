{ stdenv, lib, fetchgit, darwin, ... }:

stdenv.mkDerivation rec{
  pname = "whereami";
  rev = "cf6898544a24d55e18d87586a71d0de371c48490";
  version = (builtins.substring 0 8 rev);

  src = fetchgit {
    url = "https://github.com/victor/whereami";
    rev = rev;
    sha256 = "sha256-7z/0nHREbT8cV4/t6oZSCdWgDhhHyaOZiqRZ81dXO3I=";
  };

  buildPhase = ''
    /usr/bin/xcodebuild \
      -project whereami.xcodeproj \
      -configuration Release \
      -scheme whereami \
      CODE_SIGN_IDENTITY= SYMROOT=build OBJROOT=build SWIFT_VERSION=4.2
  '';

  meta = with lib; {
    description = "Get your geolocation from the command line ";
    longDescription = "whereami is a simple command-line utility that outputs your geographical coordinates, as determined by Core Location, which uses nearby WiFi networks with known positions to pinpoint your location. It prints them to the standard output in an easy to parse format, in good UNIX fashion.";
    homepage = "https://github.com/rancher/kim";
    licenses = licenses.mit;
    maintainers = with maintainers; [ congee ];
    mainProgram = "whereami";
    # FIXME: cannot build it due to https://github.com/NixOS/nix/issues/5748
    broken = true;
  };
}
