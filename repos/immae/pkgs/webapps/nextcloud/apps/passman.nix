{ buildApp }:
buildApp rec {
  appName = "passman";
  version = "2.2.1";
  url = "https://releases.passman.cc/${appName}_${version}.tar.gz";
  sha256 = "064pq9d0pl3y1vcywpi19fg47zy7j4h0jaxy6jklwzwcrmzagbka";
}
