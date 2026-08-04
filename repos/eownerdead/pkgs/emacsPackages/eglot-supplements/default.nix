{
  trivialBuild,
  fetchFromCodeberg,
  eglot,
  tempel,
}:
trivialBuild rec {
  pname = "eglot-supplements";
  version = "unstable";

  src = fetchFromCodeberg {
    owner = "harald";
    repo = pname;
    rev = "af5221f2f49a6d5c3a38adca4ca89bd05595a71c";
    hash = "sha256-q3eAjc3zweVMdn1OZKcr6JeKtSgOf3QapyDHNMH/UXY=";
  };

  packageRequires = [ ];
}
