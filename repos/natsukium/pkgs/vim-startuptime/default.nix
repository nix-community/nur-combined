{
  source,
  lib,
  buildGoModule,
  neovim,
  vim,
}:

buildGoModule rec {
  inherit (source) pname version src;

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  nativeCheckInputs = [
    vim
    neovim
  ];

  meta = with lib; {
    description = "A small Go program for better `vim --startuptime` alternative";
    homepage = "https://github.com/rhysd/vim-startuptime";
    changelog = "https://github.com/rhysd/vim-startuptime/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ natsukium ];
    mainProgram = "vim-startuptime";
  };
}
