{ fetchzip }:
let 
  version = "2.1.7";
in fetchzip {
  url = "https://github.com/threema-ch/threema-web/releases/download/v${version}/threema-web-${version}-gh.tar.gz";
  sha256 = "0gi1ph8xvsqfg6br0ccgrxvss78gbayyvgxl13x82293gvms1lwg";
}
