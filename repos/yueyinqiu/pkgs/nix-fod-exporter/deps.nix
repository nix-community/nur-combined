{ fetchNuGet }:
[
  (fetchNuGet {
    pname = "CliFx";
    version = "3.0.0";
    sha256 = "RMHRAQ2SQB8G3GLzG5WGKNkWNJdLCwkedSoT0iKv9gk=";
  })
  (fetchNuGet {
    pname = "CliWrap";
    version = "3.10.4";
    sha256 = "Imb2SFLSr0QZgM0A1jhtAhqdXU1tAEUd0xkdCMR/gYw=";
  })
]
