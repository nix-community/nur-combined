{ fetchFromGitHub }:

{
  version = "2018-09-19";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "3ba9d585949b0558d0fc91ee4116e9e1efe94a7d";
    sha256 = "0m4vl5xhhm2xvbvkbp5hysmmc3bjq85bvfj2ai9b81bggg0p6la9";
    name = "mcsema-source";
  };
}
