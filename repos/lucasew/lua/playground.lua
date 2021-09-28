package.path = './?.lua;./?/init.lua;' .. package.path

-- local utils = require'utils'
-- local h = require 'utils.eoq'
require 'validator'
local json = require 'dkjson'

-- utils.print_elements(lpeg)


-- local Letter = lpeg.R('az', 'AZ')
-- local Word = Letter^1 * lpeg.P" "^-1

-- local val = lpeg.Cg(Word)^1
-- print(lpeg.match(val, "lucas eduardo wendt"))

-- local Alpha = Number + Lowercase + Uppercase + Whitespace
-- local Number = lpeg.R("09")
-- local Lowercase = lpeg.R("az")
-- local Uppercase = lpeg.R("AZ")
-- local Whitespace = lpeg.P(" ")
local lpeg = require'lpeg'
local common = require'parser.common'

local WrappedLine = common.Line / function(line) return "**" .. line .. "**" end
local Text = WrappedLine ^ 1
local stmt = [[
Olá mundo

Tudo tranquileba?

Salve salve galera 123
:?:@(@)@@W)ISKđßđß→øđßðø\→sojgøß
]]
-- print(stmt)
local matches = {lpeg.match(Text, stmt)}
for k, v in pairs(matches) do
    print(k .. ": " .. v)
end


local fullStmt = [[
{
  description = "nixcfg";

  inputs = {
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld.url = "github:Mic92/nix-ld";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    nur.url = "github:nix-community/NUR/master";
    pocket2kindle = {
      url = "github:lucasew/pocket2kindle";
      flake = false;
    };
    send2kindle = {
      url = "github:lucasew/send2kindle";
      flake = false;
    };
    nixgram = {
      url = "github:lucasew/nixgram/master";
      flake = false;
    };
    dotenv = {
      url = "github:lucasew/dotenv";
      flake = false;
    };
    redial_proxy = {
      url = "github:lucasew/redial_proxy";
      flake = false;
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };
  outputs = { self, nixpkgs, nixpkgsLatest, nixgram, nix-ld, home-manager, dotenv, nur, pocket2kindle, redial_proxy, nixos-hardware, ... }@inputs:
  with import ./globalConfig.nix;
  let
    system = "x86_64-linux";
    environmentShell = ''
      function nix-repl {
        nix repl "${rootPath}/repl.nix" "$@"
      }
      export NIXPKGS_ALLOW_UNFREE=1
      export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=${builtins.toString rootPath}/compat/overlay.nix:nixpkgsLatest=${nixpkgsLatest}:home-manager=${home-manager}:nur=${nur}:nixos-config=${(builtins.toString rootPath) + "/nodes/$HOSTNAME/default.nix"}
    '';

    hmConf = home-manager.lib.homeManagerConfiguration;
    nixosConf = {mainModule, extraModules ? []}: nixpkgs.lib.nixosSystem {
      inherit pkgs;
      inherit system;
      modules = [
        revModule
        (mainModule)
      ] ++ extraModules;
    };
    overlays = [
      (import ./overlay.nix)
      (import "${home-manager}/overlay.nix")
    ];
    pkgs = import nixpkgs {
      inherit overlays;
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    revModule = ({pkgs, ...}: {
      system.configurationRevision = if (self ? rev) then 
        builtins.trace "detected flake hash: ${self.rev}" self.rev
      else
        builtins.trace "flake hash not detected!" null;
      });
    in {
      inherit overlays;
      inherit environmentShell;
      homeConfigurations = {
        main = hmConf {
          configuration = import ./homes/main/default.nix;
          inherit system;
          homeDirectory = "/home/${username}";
          inherit username;
          inherit pkgs;
        };
      };
      nixosConfigurations = {
        vps = nixosConf {
          mainModule = ./nodes/vps/default.nix;
        };
        acer-nix = nixosConf {
          mainModule = ./nodes/acer-nix/default.nix;
          extraModules = [
            nix-ld.nixosModules.nix-ld
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
          ];
        };
        bootstrap = nixosConf {
          mainModule = ./nodes/bootstrap/default.nix;
        };
      };
      inherit pkgs;
      devShell.x86_64-linux = pkgs.mkShell {
        name = "nixcfg-shell";
        buildInputs = [];
        shellHook = ''
        ${environmentShell}
        echo '${environmentShell}'
        echo Shell setup complete!
        '';
      };
      apps."${system}" = {
        pkg = {
          type = "app";
          program = "${pkgs.pkg}/bin/pkg";
        };
        webapp = {
          type = "app";
          program = "${pkgs.webapp}/bin/webapp";
        };
        pinball = {
          type = "app";
          program = "${pkgs.wineApps.pinball}/bin/pinball";
        };
        wine7zip = {
          type = "app";
          program = "${pkgs.wineApps.wine7zip}/bin/7zip";
        };
      };
    };
  }
]]
local _rest = [[
[
 ./eoq/trabson.nix
 /etc/profile.d/nhaa
 ./.
]
2
{ self, nixpkgs, nixpkgsLatest, nixgram, nix-ld, home-manager, dotenv, nur, pocket2kindle, redial_proxy, nixos-hardware, ... }@inputs: 2

a.b.c

{
    type = "app";
    program = "${pkgs.wineApps.wine7zip}/bin/7zip";
}
x.${x.a}
let x = {a = "a"}; in x.${x.a}
let x = {value = 2;}; in x
test.${a}
''hello, world${2}''
"hello, world"
let a = 2; in a
let add_a_b = { a ? 1, b ? 2 }: a + b; in add_a_b {}
v: {
    numbA = 2;
    numbB = 3;
}
[ [1 2 3] [2] ]
{}
{ a = 2 ;}
with a; a

with import ./eoq.trabson; 2
let
    system = "x86_64-linux";
    eoq = 2;
in system

with import ./eoq.trabson; let a = 2; in a
]]

local nixStmt = [[
with import ./eoq/trabson/nhaa.nix ; 2
]]


-- {nome = "lucas";}
-- [2 3 4]
--

local nix = require 'parser.nix'
common.attach_debugger(nix)
nix = lpeg.P(nix)
local ret = nix:match(nixStmt)
-- local ret = nix:match(fullStmt)
print(json.encode(ret, {indent = true}))
