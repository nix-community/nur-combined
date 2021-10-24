{ pkgs ? import <nixpkgs> {} }:
let
in pkgs.wrapVSCode {
  identifier = "main";
  extensions = [
    {
      publisher = "vscodevim";
      name = "vim";
      version = "1.21.8";
      sha256 = "sha256-cxAfLc1RtkvPEjw+SzN7eqBXPQQgadewKVzd+jJr8LU=";
    }
    {
      publisher = "bbenoist";
      name = "Nix";
      version = "1.0.1";
      sha256 = "sha256-qwxqOGublQeVP2qrLF94ndX/Be9oZOn+ZMCFX1yyoH0=";
    }
    {
      publisher = "MS-CEINTL";
      name = "vscode-language-pack-pt-BR";
      version = "1.61.4";
      sha256 = "sha256-qR7UD5SZBfW3Ihly0eP9ZHYMrKgxR4iaperP+jpI82s=";
    }
    {
      publisher = "zhuangtongfa";
      name = "Material-theme";
      version = "3.13.1";
      sha256 = "sha256-7AvsSRwYWopzbeSs0kXrNpY9MDl9QwLET+tQAtdgKrw=";
    }
    {
      publisher = "arrterian";
      name = "nix-env-selector";
      version = "0.1.2";
      sha256 = "1n5ilw1k29km9b0yzfd32m8gvwa2xhh6156d4dys6l8sbfpp2cv9";
    }
    {
      publisher = "CoenraadS";
      name = "bracket-pair-colorizer";
      version = "1.0.61";
      sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
    }
    {
      publisher = "esbenp";
      name = "prettier-vscode";
      version = "5.1.3";
      sha256 = "03i66vxvlyb3msg7b8jy9x7fpxyph0kcgr9gpwrzbqj5s7vc32sr";
    }
    {
      publisher = "donjayamanne";
      name = "githistory";
      version = "0.6.8";
      sha256 = "0wc0wsnqwyg0pz0jrmw0038k6g1p564krqscrx3h8wpyfymcd68l";
    }
    {
      publisher = "file-icons";
      name = "file-icons";
      version = "1.0.25";
      sha256 = "0s6lr7s1a0alkknazmch5k2m0r16p5gnlzn3yyan9wl8k3579c25";
    }
    {
      publisher = "zhuangtongfa";
      name = "material-theme";
      version = "3.8.5";
      sha256 = "1fdhykyddzghzs8j701q04lb2rhfrr0sbz0ib0js0shj8v31n8aa";
    }
    {
      publisher = "ms-vscode-remote";
      name = "remote-containers";
      version = "0.117.1";
      sha256 = "0kq3wfwxjnbhbq1ssj7h704gvv1rr0vkv7aj8gimnkj50jw87ryd";
    }
    {
      publisher = "alexcvzz";
      name = "vscode-sqlite";
      version = "0.8.2";
      sha256 = "0ga0blg4b459mkihxjz180mmccvvf8k4ysini8hx679zsx3mx3ip";
    }
    {
      publisher = "humao";
      name = "rest-client";
      version = "0.24.1";
      sha256 = "07jfya2pfkz51m3zljjlvsb5lwl8kdmsn1j39n8k6q8hqsjn0zml";
    }
    {
      publisher = "rust-lang";
      name = "rust";
      version = "0.7.8";
      sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
    }
    {
      publisher = "golang";
      name = "go";
      version = "0.18.0";
      sha256 = "0g9s9jc5786vj7v01c76k5n1f8blvz606z4sjhc91zqljwajgicd";
    }
  ];
  settings = {
    "workbench.iconTheme" = "file-icons";
    "workbench.colorTheme" = "One Dark Pro";
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[jsonc]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "rest-client.enableTelemetry" = false;
    "rust-client.disableRustup" = true;
    "go.useLanguageServer" = true;
  };
}
