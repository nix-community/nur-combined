{ buildFirefoxXpiAddon, lib }: {
  "wwweed" = buildFirefoxXpiAddon {
    pname = "wwweed";
    version = "2021.12.23";
    addonId = "extension-id@wwweed";
    url = "https://gitdab.com/attachments/a280a5fe-142f-4bca-a5b1-0635834ea244";
    sha256 = "1v57kvqhz7bkxf7l52yfhppnfxja080lkmljq96nh3ipwgqikavh";
    meta = with lib; {
      homepage = "https://gitdab.com/elle/wwweed";
      description = "My personal start page";
      license = licenses.unlicense;
      platforms = platforms.all;
    };
  };
}
