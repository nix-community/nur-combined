{
  lib,
  buildFHSEnv,
  stdenv,
  fetchzip,
  appimageTools
}:

let
  pname = "ogatak";
  version = "2.0.7";

  ogatak-dist = stdenv.mkDerivation {
    pname = "${pname}-dist";
    version = "2.0.7";

    src = fetchzip {
      url = "https://github.com/rooklift/ogatak/releases/download/v${version}/ogatak-${version}-linux.zip";
      hash = "sha256-3lEmZtqds1zDMlMboOMm5yQW+7zq2nnYYiB/T33GdM8=";
    };

    installPhase = ''
      mkdir -p $out/share
      cp -r $src $out/share/${pname}
      chmod +x $out/share/${pname}/ogatak
    '';
  };
in
buildFHSEnv (appimageTools.defaultFhsEnvArgs // {
  inherit pname version;
  passthru = {
    inherit pname version;
    meta = {
      mainProgram = "ogatak";
      description = "KataGo analysis GUI and SGF editor";
      homepage = "https://github.com/rooklift/ogatak";
      license = lib.licenses.agpl3Only;
    };
  };
  runScript = "${ogatak-dist}/share/${pname}/ogatak --disable-gpu-sandbox";
})

