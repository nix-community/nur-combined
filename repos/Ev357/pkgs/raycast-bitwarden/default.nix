{
  lib,
  buildNpmPackage,
  fetchgit,
  ...
}:
buildNpmPackage rec {
  pname = "raycast-bitwarden";
  version = "1.0.0";

  src =
    fetchgit {
      url = "https://github.com/raycast/extensions";
      rev = "da0541211ea1b41869002f196f09afb013b28bc1";
      sha256 = "sha256-YcjrBdqeNgC116LKzfPdz1AmupxwvkmwFBbzBDK7wCI=";
      sparseCheckout = [
        "/extensions/${pname}"
      ];
    }
    + "/extensions/${pname}";

  npmDepsHash = "sha256-jvocYE8POcfGSDCSpr015zB/5cCbx3jTaMyccO3AVIg=";

  installPhase =
    # bash
    ''
      runHook preInstall

      mkdir -p $out
      cp -r /build/.config/raycast/extensions/${pname}/* $out/

      runHook postInstall
    '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  meta = {
    description = "Access your Bitwarden vault directly from Raycast";
    homepage = "https://www.raycast.com/jomifepe/bitwarden";
    license = lib.licenses.mit;
  };
}
