{
  appimageTools,
  fetchurl,
  stdenv,
  lib,
}:

appimageTools.wrapType2 rec {
  pname = "Tangent";
  version = "0.12.1";
  src =
    let
      arch = if (stdenv.hostPlatform.isAarch64) then "-arm64" else "";
    in
    fetchurl {
      url = "https://suchnsuch-public.s3.us-east-2.amazonaws.com/Tangent/Releases/Tangent-${version}${arch}.AppImage";
      sha256 = "sha256-oZfRYEASdjLi6kJ4yZaM8ROP9DDEQR8rRjalpX7hWpM=";
    };
  meta = {
    description = "A clean and powerful open source notes app for Mac, Windows, and Linux";
    homepage = "https://www.tangentnotes.com/";
    license = lib.licenses.apsl20;
    platforms = lib.platforms.linux;
  };
}
