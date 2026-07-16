{
  jetbrains,
  fetchurl,
  lib,
}:
(jetbrains.idea.overrideAttrs (oldAttrs: {
  src = fetchurl {
    url = "https://github.com/JetBrains/intellij-community/releases/download/idea%2F2026.1.4/idea-2026.1.4.tar.gz";
    hash = "sha256-KHtR6ddNli8HCGvLHpW/W6F/4Jbhn1cIIt5uHEKXm2k=";
  };

  pname = "idea-oss";
  dontBuild = true;
  wmClass = "jetbrains-idea-community";
  product = "IntelliJ IDEA Community";
  productShort = "IDEA";

  version = "2026.1.4";
  buildNumber = "261.26222.65";
  meta = (oldAttrs.meta or {}) // {
    license = lib.licenses.asl20;
  };
}))
