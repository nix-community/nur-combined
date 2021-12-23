{ buildFirefoxXpiAddon, lib }:
{
  "wwweed" = buildFirefoxXpiAddon {
    pname = "wwweed";
    version = "2021.12.23";
    addonId = "extension-id@wwweed";
    url = "https://gitdab.com/attachments/27b7c3bc-aaa1-4e2e-912f-730765674516";
    sha256 = "00mb32jvw66w5v1s4wkiygnbwmw57npbhnxi3bkd5bbw6380h025";
    meta = with lib; {
      homepage = "https://gitdab.com/elle/wwweed";
      description = "My personal start page";
      license = licenses.unlicense;
      platforms = platforms.all;
    };
  };
}
