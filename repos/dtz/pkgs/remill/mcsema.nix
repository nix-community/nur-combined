{ fetchFromGitHub }:

{
  version = "2018-09-23";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "e252733415220043d429e88cd312145d46bb97b3";
    sha256 = "1hicj4ns5mxcp8xqni8zpm2alsv3v8ikbi766j6jx037b0020g15";
    name = "mcsema-source";
  };
}
