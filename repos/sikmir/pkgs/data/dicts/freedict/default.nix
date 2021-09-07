{ callPackage }:

{
  deu-eng = callPackage ./base.nix {
    lang = "deu-eng";
    version = "1.8.1-fd0.2.1";
    hash = "sha256-FJP9vrzz/A2PwFDBOTtFGMc5OoiK7KE6qnAnG/mnXMU=";
  };
  eng-rus = callPackage ./base.nix {
    lang = "eng-rus";
    version = "0.3.1";
    hash = "sha256-3rQUFUbCa8YLsP//rTieSfBr4iRqOhSUtWm9o7CU44c=";
  };
  epo-eng = callPackage ./base.nix {
    lang = "epo-eng";
    version = "1.0.1";
    hash = "sha256-3+qZvvY8dmnxsKsLL4kBTpAywKMDRXIeqLYNwhzmvSQ=";
  };
  fin-eng = callPackage ./base.nix {
    lang = "fin-eng";
    version = "2020.10.04";
    hash = "sha256-sJXH/n2Rdf18zYmpgVuRc38di1jzC0CRJiM1cXEA3n8=";
  };
}
