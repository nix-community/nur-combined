{ buildApp }:
buildApp rec {
  appName = "metadata";
  version = "0.10.0";
  url = "https://github.com/gino0631/nextcloud-metadata/releases/download/v${version}/${appName}.tar.gz";
  sha256 = "1qqgzk0b13k5gfy9sdjqm9v325lm8qn7ikv3a8d21pzzqii6402x";
}
