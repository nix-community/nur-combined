# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  age-plugin-openpgp-card = {
    pname = "age-plugin-openpgp-card";
    version = "v0.1.1";
    src = fetchFromGitHub {
      owner = "wiktor-k";
      repo = "age-plugin-openpgp-card";
      rev = "v0.1.1";
      fetchSubmodules = false;
      sha256 = "sha256-uJmYtc+GxJZtCjLQla/h9vpTzPcsL+zbM2uvAQsfwIY=";
    };
  };
  huawei-password-tool = {
    pname = "huawei-password-tool";
    version = "v1.0.0";
    src = fetchFromGitHub {
      owner = "0xuserpag3";
      repo = "HuaweiPasswordTool";
      rev = "v1.0.0";
      fetchSubmodules = false;
      sha256 = "sha256-uvLY+/XAE62Ft+bEm2t5SNhXb5nrWPQouJEdAkrguYg=";
    };
  };
  thinkpad-uefi-sign = {
    pname = "thinkpad-uefi-sign";
    version = "b502420583b8a38d4b3e706b20a51a435740f749";
    src = fetchFromGitHub {
      owner = "thrimbor";
      repo = "thinkpad-uefi-sign";
      rev = "b502420583b8a38d4b3e706b20a51a435740f749";
      fetchSubmodules = false;
      sha256 = "sha256-FqyrTZQWSKcDLLrG6jfrrW+vtAOUgE65C5jP3v3To8U=";
    };
    date = "2020-06-26";
  };
  webcrack = {
    pname = "webcrack";
    version = "v2.15.1";
    src = fetchFromGitHub {
      owner = "j4k0xb";
      repo = "webcrack";
      rev = "v2.15.1";
      fetchSubmodules = false;
      sha256 = "sha256-9xCndYtGXnVGV6gXdqjLM4ruSIHi7JRXPHRBom7K7Ds=";
    };
  };
}
