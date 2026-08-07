{ lib, self, ... }:

let
  port = 12345;

  domain = "git-pages.localhost";
  preview-domain = "git-pages-preview.localhost";
in
{
  name = "git-pages";

  nodes.server = { config, ... }: {
    imports = [ self.nixosModules.git-pages ];

    services.git-pages = {
      enable = true;
      settings = {
        server = {
          pages = "tcp/127.0.0.1:${toString port}";
        };
        wildcard = [
          # TODO: add forgejo deploy check
          {
            authorization = "forgejo";
            clone-url = "https://${config.services.forgejo.settings.server.DOMAIN}/<user>/<project>.git";
            inherit domain preview-domain;
            index-repo = "pages";
            index-repo-branch = "main";
            max-preview-lifetime = 7;
          }
        ];
      };
    };
  };

  testScript = ''
    start_all()
    with subtest("start git-pages"):
        server.wait_for_unit("git-pages.service")
        server.wait_for_open_port(${toString port})
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
