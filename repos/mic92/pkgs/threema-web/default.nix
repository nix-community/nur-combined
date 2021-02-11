{ fetchzip }:
let
  version = "2.3.8";
in
fetchzip {
  url = "https://github.com/threema-ch/threema-web/releases/download/v${version}/threema-web-${version}-gh.tar.gz";
  sha256 = "sha256-2UGjcc7LVg15eNIF3fivMYQ9GuyNw4IR6gWK4t1yVds=";
}
