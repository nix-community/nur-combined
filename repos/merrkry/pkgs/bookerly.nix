{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "bookerly";
  version = "2020.03";

  src = fetchzip {
    url = "https://m.media-amazon.com/images/G/01/mobile-apps/dex/alexa/branding/Amazon_Typefaces_Complete_Font_Set_Mar2020.zip";
    hash = "sha256-CK7WSXkJkcwMxwdeW31Zs7p2VdZeC3xbpOnmd6Rr9go=";
  };

  strictDeps = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 -t "$out/share/fonts/truetype" Bookerly/*.ttf "Bookerly Display"/*.ttf
    install -Dm644 "Amazon Ember Licensing Guidelines.pdf" \
      "$out/share/doc/${finalAttrs.pname}/Amazon-Type-Library-Usage-Guidelines.pdf"

    runHook postInstall
  '';

  meta = {
    description = "Serif font family designed for Amazon Kindle";
    homepage = "https://developer.amazon.com/en-US/alexa/branding/echo-guidelines/identity-guidelines/typography";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.all;
  };
})
