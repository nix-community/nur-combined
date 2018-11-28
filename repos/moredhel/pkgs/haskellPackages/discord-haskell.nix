{ fetchFromGitHub, mkDerivation, aeson, async, base, base64-bytestring, bytestring
, containers, data-default, http-client, iso8601-time, JuicyPixels
, MonadRandom, req, safe-exceptions, stdenv, text, time
, unordered-containers, vector, websockets, wuss
}:
mkDerivation {
  pname = "discord-haskell";
  version = "0.6.0";
  src = fetchFromGitHub {
    owner = "moredhel";
    repo = "discord-haskell";
    sha256 = "0v6kij1h0gm5jmccy4jr42h8jh8x4bhdf7wddb4d169xysmqjkgm";
    rev = "006ec4246399740153c8d8dd126924582b7c687b";
    fetchSubmodules = false;
  };

  libraryHaskellDepends = [
    aeson async base base64-bytestring bytestring containers
    data-default http-client iso8601-time JuicyPixels MonadRandom req
    safe-exceptions text time unordered-containers vector websockets
    wuss
  ];
  homepage = "https://github.com/moredhel/discord-haskell";
  description = "Write bots for Discord in Haskell";
  license = stdenv.lib.licenses.mit;
}
