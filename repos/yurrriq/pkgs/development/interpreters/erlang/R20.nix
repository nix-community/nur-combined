{ mkDerivation }:

mkDerivation rec {
  version = "20.3.8.5";
  sha256 = "1ar6ap3ahv0fx731g7n5z5sslilyd93q59imymbjhjvxhw15ylzw";

  prePatch = ''
    substituteInPlace configure.in --replace '`sw_vers -productVersion`' '10.10'
  '';
}
