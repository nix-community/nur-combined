{ lib
, stdenv
, fetchFromGitHub
,
}:
## Usage
# In NixOS, simply add this package to services.udev.packages:
#   services.udev.packages = [ pkgs.opensk-udev-rules ];
stdenv.mkDerivation (finalAttrs: {
  pname = "opensk-udev-rules";

  version = "2.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "OpenSK";
    rev = "ctap${finalAttrs.version}";
    sha256 = "sha256-JeBaSS6XzFOC22beWA3F9o1AJFzg5i346xU34LY9efk=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -D rules.d/55-opensk.rules $out/lib/udev/rules.d/55-opensk.rules
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/google/OpenSK";
    description = "Official OpenSK udev rules list";
    platforms = platforms.linux;
    license = licenses.asl20;
    maintainers = with maintainers; [ oluceps ];
  };
})
