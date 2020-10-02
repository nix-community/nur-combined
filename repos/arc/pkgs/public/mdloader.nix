{ stdenv, writeText, fetchFromGitHub }: stdenv.mkDerivation rec {
  pname = "mdloader";
  version = "1.05";

  src = fetchFromGitHub {
    owner = "Massdrop";
    repo = "mdloader";
    rev = version;
    sha256 = "0m2rwd5dyljdhrabqlna5fsgy879bz9606bk1122rzckx3n8wg8q";
  };

  patches = [ (writeText "mdloader.patch" ''
    --- a/mdloader_common.c
    +++ b/mdloader_common.c
    @@ -731,7 +731,7 @@ int main(int argc, char *argv[])
         char appletfname[128] = "";
         strlower(mcu->name);

    -    sprintf(appletfname, "applet-flash-%s.bin", mcu->name);
    +    sprintf(appletfname, APPLETDIR "applet-flash-%s.bin", mcu->name);
         printf("Applet file: %s\n", appletfname);

         fIn = fopen(appletfname, "rb");
  '') ];

  makeFlags = ''CFLAGS=-DAPPLETDIR='"${placeholder "out"}/lib/mdloader/"' '';

  installPhase = ''
    install -Dm0755 -t $out/bin build/mdloader
    install -Dm0644 -t $out/lib/mdloader applet-flash-*.bin
  '';

  meta = {
    platforms = stdenv.lib.platforms.linux;
  };
}
