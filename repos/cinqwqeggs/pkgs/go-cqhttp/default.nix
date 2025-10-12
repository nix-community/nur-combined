# default.nix
{ pkgs, lib, buildGoModule, fetchFromGitHub }:


let version = "1.2.0"; in 

buildGoModule rec {
  pname = "go-cqhttp";
  inherit version;

 
  src = fetchFromGitHub {
    owner = "Mrs4s";
    repo = "go-cqhttp";
    rev = "v${version}"; 
    
    
    hash = "sha256-Vc/k4mb1JramT2l+zu9zZQa65gP5XvgqUEQgle1vX8w="; 
  };

  
  vendorHash = "sha256-tAvo96hIWxkt3rrrPH5fDKwfwuc76Ze0r55R/ZssU4s=";

  
  
  
  meta = with lib; {
    description = "基于 Mirai/MiraiGo 的 OneBot Golang 原生实现";
    homepage = "https://github.com/Mrs4s/go-cqhttp";
    sourceProvenance = [ 
      {
        type = "url"; 
        value = "https://github.com/Mrs4s/go-cqhttp/archive/v${version}.tar.gz"; 
        hash = src.name;
        isSource = true; 
      }
    ];
    maintainers = with lib.maintainers; [ "cinqwqeggs" ];
    mainProgram = "go-cqhttp";
    license = licenses.agpl3Only; 
    platforms = platforms.unix; 
  };
}
