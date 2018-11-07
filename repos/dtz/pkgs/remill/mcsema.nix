{ fetchFromGitHub }:

{
  version = "2018-11-01";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "1ef3ed2cd355f52d7ae28b336bdbc59c5ebad5b9";
    sha256 = "0ndbk8wqbz1d01v6vw92bdn00zbnbnh0gclpaanyc20kqvc1h05s";
    name = "mcsema-source";
  };
}
