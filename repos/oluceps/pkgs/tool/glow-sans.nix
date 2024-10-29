{
  pname,
  version,
  sha256,
  lang,
}:
{
  stdenv,
  fetchurl,
  unzip,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {

  inherit pname version sha256;
  src = fetchurl {
    url = "https://github.com/welai/glow-sans/releases/download/v${version}/GlowSans${lang}-Normal-v${version}.zip";
    inherit sha256;
  };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  setSourceRoot = "sourceRoot=`pwd`";
  nativeBuildInputs = [ unzip ];
  installPhase = ''
    find . -name '*.otf'    -exec install -Dt $out/share/fonts/opentype {} \;
  '';

  meta = with lib; {
    homepage = "https://github.com/welai/glow-sans";
    description = ''
      SHSans-derived CJK font family with a more concise & modern look
    '';
    license = with licenses; [
      mit
      ofl
    ];
    platforms = platforms.all;
    maintainers = with maintainers; [ oluceps ];
  };
})
