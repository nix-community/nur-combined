{ buildApp }:
buildApp rec {
  appName = "flowupload";
  version = "0.1.0";
  url = "https://github.com/e-alfred/${appName}/releases/download/${version}/${appName}.tar.gz";
  sha256 = "0cai76hcjrwvq32yav0nd9kkhslandp1sj5czz119gsfjlkpalw9";
}
