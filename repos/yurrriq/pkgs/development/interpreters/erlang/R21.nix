{ mkDerivation }:

mkDerivation rec {
  version = "21.0.5";
  sha256 = "08bw8zl1w0s47rsy52ryx0hgxacw37a39k5m20p8mfrvflkaqip7";

  prePatch = ''
    substituteInPlace configure.in --replace '`sw_vers -productVersion`' '10.10'
  '';
}
