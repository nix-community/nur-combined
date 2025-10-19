{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation {
  pname = "arcconf";
  version = "v4.01.24763";

  src = fetchzip {
    # NOTE: No longer available from Adaptec's site, and wasn't archived by the
    # wayback machine, but the one from this URL matches the sha256 hash from
    # the AUR for it, so probably fine.
    url = "https://repo.nepustil.net/distfiles/arcconf_v4_01_24763.zip";
    sha256 = "sha256-UQK3pTIBfCl48Zxf6Tc7n5o0hh7uBigYS9wn0Etolig=";
    stripRoot = false;
  };

  installPhase = ''
    install -m755 -D linux_64/static_arcconf/cmdline/arcconf $out/bin/arcconf
  '';

  dontPatchELF = true;
  dontStrip = true;

  meta = with lib; {
    description = "Microsemi Adaptec ARCCONF command line interface utility";
    homepage = "https://storage.microsemi.com/en-us/speed/raid/storage_manager/arcconf_v4_01_24763_zip.php";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = {
      fullName = "Microsemi License for arcconf_4_01_247632.zip";
      url = "https://storage.microsemi.com/en-us/support/_eula/license.php?arcconf_4_01_247632.zip";
      free = false;
    };
  };
}
