{ buildGoModule, fetchFromGitHub, lib, hostPlatform, darwin }: buildGoModule rec {
  pname = "git-annex-remote-b2";
  version = "2020-02-05-arc";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "6e6b80b809d3d6e1e98517ed714d69c0531d21dc";
    sha256 = "13mb3y9j1ndnlqwqn4s7x92bapbvb8dc8mg5l61kkhlb6qcrw2j4";
  };

  modSha256 = "0xdmiwfkj84rh81w5wkd8cnvg0vsv5jv748l5ggj038bq0hmvrp2";
  vendorSha256 = "1wsy55n7jcgk07siwjl7fgq9i63x05clki181rzx44r337hv93g5";
  buildInputs = lib.optional hostPlatform.isDarwin darwin.apple_sdk.frameworks.Security;
}
