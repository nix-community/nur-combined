{ callPackage }:

{
  deu-eng = callPackage ./base.nix {
    lang = "deu-eng";
    version = "0.3.5";
    hash = "sha256-9dHEogR1uJtTm3xCVIxdZ8nNoNT2iee11viOQQZFxms=";
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
