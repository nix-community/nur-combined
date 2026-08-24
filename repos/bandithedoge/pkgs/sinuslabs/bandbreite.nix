{ fetchzip, sinuslabs }:
sinuslabs.mkSinuslabs (finalAttrs: {
  pname = "bandbreite";
  version = "1.1.0";
  src = fetchzip {
    url = "https://github.com/Sinuslabs/Bandbreite/releases/download/${finalAttrs.version}/Bandbreite-Linux.zip";
    sha256 = "sha256-CFz9mTwJ/oSsTpshzrlopiYSYnAVTqaDlYtFMHgtTtE=";
  };

  meta = {
    description = "Add warm, analog character to your drums, basses, and 808s";
    homepage = "https://sinuslabs.io/products/bandbreite";
  };
})
