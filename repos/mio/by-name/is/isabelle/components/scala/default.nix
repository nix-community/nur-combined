{
  scala_3,
  fetchurl,
}:

scala_3.bare.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "3.3.8";

    outputs = [
      "out"
      "settings"
    ];

    src = fetchurl {
      url = "https://isabelle.in.tum.de/components/scala-${finalAttrs.version}-1.tar.gz";
      hash = "sha256-UXpG3L6+P0FXhmBi1iNj78UEBYdqUvcdOfr3yVLG/T4=";
    };

    postPatch = ''
      rm LICENSE README VERSION
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv * $out

      runHook postInstall
    '';

    postInstall = ''
      mkdir -p $settings/etc
      substitute $out/etc/settings $settings/etc/settings \
        --replace-fail '$COMPONENT' "$out"
      rm -rf $out/etc
    '';
  }
)
