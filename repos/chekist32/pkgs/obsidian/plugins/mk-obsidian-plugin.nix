{
  lib,
  stdenv,
  fetchurl,
}:
{
  name,
  version,
  repo,

  mainJsSha256,
  manifestSha256,
  stylesCssSha256 ? null,

  description ? "",
  license ? lib.licenses.mit,
}:
stdenv.mkDerivation (
  {
    pname = "obsidian-plugin-${name}";
    inherit version;

    mainJs = fetchurl {
      url = "${repo}/releases/download/${version}/main.js";
      sha256 = mainJsSha256;
    };
    manifest = fetchurl {
      url = "${repo}/releases/download/${version}/manifest.json";
      sha256 = manifestSha256;
    };

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp $mainJs $out/main.js
      cp $manifest $out/manifest.json
      ${lib.optionalString (stylesCssSha256 != null) "cp $stylesCss $out/styles.css"}
    '';

    meta = {
      homepage = repo;
      changelog = "${repo}/releases/tag/${version}";
      inherit description;
      license = [ license ];
    };
  }
  // lib.optionalAttrs (stylesCssSha256 != null) {
    stylesCss = fetchurl {
      url = "${repo}/releases/download/${version}/styles.css";
      sha256 = stylesCssSha256;
    };
  }
)
