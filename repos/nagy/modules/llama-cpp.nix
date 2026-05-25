{ pkgs, ... }:

let
  self = import ../. { inherit pkgs; };
in
{

  environment.systemPackages = [
    pkgs.llama-cpp-vulkan
    pkgs.aichat
    self.llm-ttok
  ];

}
