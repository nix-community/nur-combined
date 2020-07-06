{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.vscode;
in
{
  options = {
    profiles.dev.vscode = {
      enable = mkEnableOption "Enable VS Code profile";
    };
  };
  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      userSettings = {
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.colorTheme" = "plain";
        "editor.fontFamily" = "'Fira Code','Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
        "[nix]"."editor.tabSize" = 2;
        "editor.minimap.enabled" = false;
        "window.titleBarStyle" = "custom";
        "breadcrumbs.enabled" = true;
        "go.useLanguageServer" = true;
      };
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh";
          publisher = "ms-vscode-remote";
          version = "0.42.2";
          sha256 = "0aqjlbndiq1q8gh4dkj68sbr56ya458c8xh7f8bkhw5rnmz31pj5";
        }
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.42.2";
          sha256 = "0qkdz1ng5mk35x8awa9wavb138hd454da8gsf7m66xyfifsmcn6h";
        }
        {
          name = "remote-ssh-explorer";
          publisher = "ms-vscode-remote";
          version = "0.42.2";
          sha256 = "02wg1bvl9923ldxlkj0qdlpf0njrd2r805561dkw5yp8siiim768";
        }
        {
          name = "EditorConfig";
          publisher = "EditorConfig";
          version = "0.12.4";
          sha256 = "067mxkzjmgz9lv5443ig7jc4dpgml4pz0dac0xmqrdmiwml6j4k4";
        }
        {
          name = "vsc-material-theme";
          publisher = "Equinusocio";
          version = "2.6.3";
          sha256 = "1ghqp0yfcpcnjcwgvxw7aix9fj5q8kr0i97lmzlw2jqslmyvxg5x";
        }
        {
          name = "material-icon-theme";
          publisher = "PKief";
          version = "3.6.0";
          sha256 = "0jphqqs41pkyv11mq1a3wzx14sl6pifcfyz3lw5wany003fv5s9s";
        }
        {
          name = "fish-vscode";
          publisher = "skyapps";
          version = "0.2.0";
          sha256 = "148r186y3h7n84fcyh6wa2qwl2q3pfi8aykwkc9dhfj3kwfcm5rb";
        }
        {
          name = "code-runner";
          publisher = "formulahendry";
          version = "0.9.4";
          sha256 = "08qq21gaa7igklv9si35qxhs79na893vyp96hf7rvyv7c4fn1pvw";
        }
        {
          name = "gitlens";
          publisher = "eamodio";
          version = "8.5.6";
          sha256 = "1vn6fvxn4g3759pg9rp8hqdc58pgyvcdma1ylfwmdnipga37xfd3";
        }
        {
          name = "vscode-direnv";
          publisher = "Rubymaniac";
          version = "0.0.2";
          sha256 = "1gml41bc77qlydnvk1rkaiv95rwprzqgj895kxllqy4ps8ly6nsd";
        }
        {
          name = "vscode-proto3";
          publisher = "zxh404";
          version = "0.2.1";
          sha256 = "12yf66a9ws5hlyj38nmn91y8a1jrq8696fnmgk60w9anyfalbn4q";
        }
        {
          name = "project-manager";
          publisher = "alefragnani";
          version = "9.0.1";
          sha256 = "0aqyavgpaqvv62q15h4dkxcgj4khsgr1rlzr3wi9aflyncg7addb";
        }
        {
          name = "tslint";
          publisher = "eg2";
          version = "1.0.39";
          sha256 = "1al61xzz7p6rqgk7rplg3njj4hyiipx7w89pqfn8634skw7r32rl";
        }
        {
          name = "vscode-npm-script";
          publisher = "eg2";
          version = "0.3.5";
          sha256 = "1v4081siab0fm0zfn6vlvqlc4vx131q8y6f3h3l46mvpndsa2rck";
        }
        {
          name = "vscode-pull-request-github";
          publisher = "GitHub";
          version = "0.1.6";
          sha256 = "08r0i265q4gk6kmz3ynxglhssdk5020bifagl9jr8spfs5sacnsx";
        }
        {
          name = "vscode-kubernetes-tools";
          publisher = "ms-kubernetes-tools";
          version = "0.1.14";
          sha256 = "0ixs1cydbz6qizf9cs0jdqpxwfg7gs74jdy9hp2v9h8q7vq6503l";
        }
        # languages
        {
          name = "Go";
          publisher = "ms-vscode";
          version = "0.6.89";
          sha256 = "05mzw4bwsa9wxldnkdgk0b4n4xm8gzhmrbqy6j8lbk3p360wdg8z";
        }
        {
          name = "rust";
          publisher = "rust-lang";
          version = "0.4.10";
          sha256 = "1y7sb3585knv2pbq7vf2cjf3xy1fgzrqzn2h3fx2d2bj6ns6vpy3";
        }
        {
          name = "crates";
          publisher = "serayuzgur";
          version = "0.3.2";
          sha256 = "0xn24vghmcf8fi8cdgaa3f0npmkdr4fdn9y1g56l2fzrx2z4rw3q";
        }
        {
          name = "Kotlin";
          publisher = "mathiasfrohlich";
          version = "1.7.0";
          sha256 = "1d81rgfh1c1wkz4la0mmjj6k28if237f835diyk3z6n63cazapli";
        }
        {
          name = "java";
          publisher = "redhat";
          version = "0.31.0";
          sha256 = "1hzqiqkja4931k7rb4pmva6k80ss53nvyksiqvq6kxj25rg3kd1b";
        }
        {
          name = "vscode-java-debug";
          publisher = "vscjava";
          version = "0.13.0";
          sha256 = "11xvd1b0qsvrbm4yb0c7fm537p1gs6wz45xzl6v1a7k08dapi20i";
        }
        {
          name = "vscode-java-test";
          publisher = "vscjava";
          version = "0.9.0";
          sha256 = "0000v5qh100n3n529r1nzx79cawx83kvprrmhw6pb4j0m5b3p3p2";
        }
        {
          name = "gradle-language";
          publisher = "naco-siren";
          version = "0.2.3";
          sha256 = "15lzxvym0mkljjn57av1p4z6hqqwbsbn5idw2fn7nccgrl93aywf";
        }
        {
          name = "vscode-yaml";
          publisher = "redhat";
          version = "0.0.16";
          sha256 = "0v21qj65nrp850r0jmivmsm9y5i99ymxxm8ganzdia4vbv5hzx9r";
        }
        {
          name = "better-toml";
          publisher = "bungcip";
          version = "0.3.2";
          sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
        }
        {
          name = "plain";
          publisher = "konstantin";
          version = "0.0.7";
          sha256 = "0qbn8bdcbvz8qfjb42n4j9asmsd6zf33w9ypyinb7x37ylw482nx";
        }
      ] ++ [
        pkgs.vscode-extensions.bbenoist.Nix
        pkgs.vscode-extensions.ms-python.python
        # pkgs.vscodeliveshare
      ];
    };
  };
}
