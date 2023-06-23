{ config, lib, pkgs, ... }:

(pkgs.python310.overrideAttrs (old: {
  src = pkgs.fetchFromGitHub {
    owner = "zq1997";
    repo = "RegCPython";
    rev = "a589237";
    sha256 = "sha256-baHSTh0JRuAiG0HORk0NlCDmIB4njW00tPNOF0lXu60=";
  };
  version = "3.10.11";
})).override {
  sourceVersion = {
    major = "3";
    minor = "10";
    path = "11";
    patch = "";
    suffix = "regc";
  };
}
