# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  alist = {
    pname = "alist";
    version = "v3.40.0";
    src = fetchFromGitHub {
      owner = "alist-org";
      repo = "alist";
      rev = "v3.40.0";
      fetchSubmodules = false;
      sha256 = "sha256-D2XwY2D5WS7VoidmpEM5KyMA1NsZjlUV6Xs2uSj6+BE=";
    };
  };
}
