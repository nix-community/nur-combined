{ pkgs, lib, luaOlder, luaAtLeast, fetchurl, fetchFromGitHub
, buildLuarocksPackage, compat53, argparse, luafilesystem }:

buildLuarocksPackage rec {
  pname = "tl";

  # version = "0.13.2-1";
  # src = fetchurl {
  #   url = "mirror://luarocks/tl-${version}.src.rock";
  #   sha256 = "13zq2gqsds9s4xxk50xp89i29kaf33cad9ngcpf5chh028nw03is";
  # };

  version = "dev-1";
  src = fetchFromGitHub {
    owner = "teal-language";
    repo = "tl";
    rev = "cfb009880bff80ed5f35eaa4c0f5d5fb8bb21e40";
    sha256 = "sha256-UliBxm8g6QFaEMPUAgQnCNj8gdeX8n686pQ9zec4SFA=";
  };

  disabled = (luaOlder "5.3") || (luaAtLeast "5.5");

  propagatedBuildInputs = [ compat53 argparse luafilesystem ];

  meta = with pkgs.lib; {
    description = "Typed Lua that compiles to Lua";
    homepage = "https://github.com/teal-language/tl";
    license = licenses.mit;
  };
}
