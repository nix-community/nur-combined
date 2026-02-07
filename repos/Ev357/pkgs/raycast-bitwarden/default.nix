{
  lib,
  buildNpmPackage,
  fetchgit,
  ...
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "1.0.0";

  src =
    fetchgit {
      url = "https://github.com/raycast/extensions";
      rev = "4a6e46f1dae389a4f8c52f12eb5722542cdfe6f3";
      sha256 = "sha256-/kVt//0L7KnwDMTW/JzixTDWeAj/e36YOwT4OKYFUCU=";
      sparseCheckout = [
        "/extensions/${pname}"
      ];
    }
    + "/extensions/${pname}";

  patches = [
    ./windows-shortcut-casing.patch
  ];

  npmDepsHash = "sha256-f4YTY0PxAfZ3boxNSUNVHIePxvU1KZXCBLum+j1hEL4=";

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
