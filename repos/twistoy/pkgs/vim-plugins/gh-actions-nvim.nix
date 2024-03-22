{
  buildVimPlugin,
  fetchFromGitHub,
  rustPlatform,
  luajit,
  pkg-config,
  ...
}: let
  version = "2024-02-20";
  gh-actions-nvim-src = fetchFromGitHub {
    owner = "topaxi";
    repo = "gh-actions.nvim";
    rev = "4e19683aa581d8670d99e74104610a673f11964d";
    sha256 = "RivPNOv3P7fADBriDY4TyRMZJqISlabKFYJIxiQWXyc=";
  };
  gh-actions-nvim-bin = rustPlatform.buildRustPackage {
    pname = "gh-actions-nvim-bin";
    inherit version;
    src = gh-actions-nvim-src;

    nativeBuildInputs = [
      luajit
      pkg-config
    ];
    buildInputs = [
      luajit
    ];

    cargoSha256 = "tfyYRiRpe1QxAfW02PqWxQGj43TD3YOck7lZ9psLd2s=";
  };
in
  buildVimPlugin {
    pname = "gh-actions-nvim";
    inherit version;
    src = gh-actions-nvim-src;
    propagatedBuildInputs = [gh-actions-nvim-bin];
    preFixup = ''
      mkdir -p "$out/lua/deps/"
      cp "${gh-actions-nvim-bin}/lib/libgh_actions_rust.dylib" "$out/lua/libgh_actions_rust.so" || true
      cp "${gh-actions-nvim-bin}/lib/libgh_actions_rust.so" "$out/lua/libgh_actions_rust.so" || true
    '';
    meta = {
      homepage = "https://github.com/topaxi/gh-actions.nvim";
      description = "See status of workflows and dispatch runs directly in neovim";
    };
  }
