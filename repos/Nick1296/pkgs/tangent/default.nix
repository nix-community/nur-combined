{
  appimageTools,
  fetchurl,
  stdenv,
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
}
