{ lib, buildVimPlugin, fetchFromGitHub }:

{
  KSP-Syntax = buildVimPlugin {
    pname = "KSP-Syntax";
    version = "2014-06-29";
    src = fetchFromGitHub {
      owner = "mic47";
      repo = "KSP-Syntax";
      rev = "1eaa4bfec4001b613b1fc26e38e365e1e836a65e";
      hash = "sha256-C6XzE0DH8b00rZDkSBEKSjUo9wfdL6Z+NzRNXLHplJk=";
    };
    meta.homepage = "https://github.com/mic47/KSP-Syntax";
  };
}
