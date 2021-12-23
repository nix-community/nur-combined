{ buildFirefoxXpiAddon, lib }:
{
  "wwweed" = buildFirefoxXpiAddon {
    pname = "wwweed";
    version = "2021.12.11";
    addonId = "extension-id@wwweed";
    url = "https://gitdab.com/attachments/0c7cf19a-e0e0-494d-8875-e12286f1cb35";
    sha256 = "1m5jbcmdyyrz7p32rq4mnclmn84wn26xkx10044d9ys86348m5p3";
    meta = with lib; {
      homepage = "https://gitdab.com/elle/wwweed";
      description = "My personal start page";
      license = licenses.unlicense;
      platforms = platforms.all;
    };
  };
}
