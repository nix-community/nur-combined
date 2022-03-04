{ buildGoModule, fetchFromGitHub }:

buildGoModule {
  pname = "lightspeed-webrtc";
  version = "20210504-a3d0d97fa9bd2f0d2eb7ca1745b6212b75959a12";

  src = fetchFromGitHub {
    owner = "GRVYDEV";
    repo = "Lightspeed-webrtc";
    rev = "a3d0d97fa9bd2f0d2eb7ca1745b6212b75959a12";
    sha256 = "sha256-B5Gy1X1NH7iPdyOCZsHc+PrhT+pUHaK+fhE4nkT6q+4=";
  };

  vendorSha256 = "sha256-RaVmHOktDiOLL7ioDpbKWXyo9oA84Q939e2qxZJjk6k=";
}
