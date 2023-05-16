{ pkgs ? import <nixpkgs> {}, ... }:
{
  identifier = "programming";
  imports = [
    ./common.nix
  ];
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
      publisher = "esbenp";
      name = "prettier-vscode";
      version = "5.1.3";
      sha256 = "03i66vxvlyb3msg7b8jy9x7fpxyph0kcgr9gpwrzbqj5s7vc32sr";
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
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[jsonc]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "rust-client.disableRustup" = true;
    "go.useLanguageServer" = true;
  };
}
