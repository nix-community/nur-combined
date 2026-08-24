{ fetchzip, sinuslabs }:
sinuslabs.mkSinuslabs (finalAttrs: {
  pname = "ko";
  version = "1.3.0";
  src = fetchzip {
    url = "https://github.com/Sinuslabs/KO/releases/download/${finalAttrs.version}/KO-Linux.zip";
    sha256 = "sha256-txmktKPfHxPD/pwhKgzP8z8jMgfAeuDLI0a4ePuRRh0=";
  };

  meta = {
    description = "KO is heavy hitting saturation and processing tool. Knockout power";
    homepage = "https://sinuslabs.io/products/ko";
  };
})
