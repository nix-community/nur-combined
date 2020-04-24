{ buildApp }:
buildApp rec {
  appName = "cookbook";
  version = "0.5.4";
  url = "https://github.com/mrzapp/nextcloud-cookbook/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "1dav07jylmw9n05l7p3m20ywky27nrg3gna271mly5bvs9q6kanm";
  installPhase = ''
    sed -i -e "s/application..ld..json/application[^\"|\\\\']*ld[^\"|\\\\']*json/" lib/Service/RecipeService.php
    mkdir -p $out
    cp -R . $out/
    '';
}

