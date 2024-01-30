{ pkgs, stdenv, ... }:

let
  unimatrix = (
    pkgs.fetchgit {
      url = "https://github.com/will8211/unimatrix";
      name = "unimatrix";
      hash = "sha256-QN2YunUN0nHD6aa4praWYy+o6lmPMFzR3rnVdEJw6fc=";
    }
  );
in unimatrix
