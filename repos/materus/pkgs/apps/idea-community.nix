{
  jetbrains,
  fetchurl,
  lib,
}:
(jetbrains.idea.overrideAttrs (oldAttrs: {
  src = fetchurl {
    url = "https://github.com/JetBrains/intellij-community/releases/download/idea%2F2026.1.3/idea-2026.1.3.tar.gz";
    hash = "sha256-VNeTjX2JL8c4iQmGt0EVz07RHX50usaIjpEuzXg9uDc=";
  };

  pname = "idea-oss";
  dontBuild = true;
  wmClass = "jetbrains-idea-community";
  product = "IntelliJ IDEA Community";
  productShort = "IDEA";

  version = "2026.1.3";
  buildNumber = "261.25134.95";
  meta = (oldAttrs.meta or {}) // {
    license = lib.licenses.asl20;
  };
}))
