{ self, config, inputs, pkgs, ... }:
{
	users.users.server = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
    group = "server";
		password = "changeme";
	};
  users.groups.server = {};

  home-manager.extraSpecialArgs = {
    inherit self;
    hostname = config.networking.hostName;
  };

  home-manager.users.server = {
    services.vscode-server.enable = true;
    imports = [
      "${inputs.vscode-server}/modules/vscode-server/home.nix"
      ../common/home.nix
    ];
    home.packages = with pkgs; [
      socat
    ];
  };

  users.users.server.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAgNB1nsKZ5KXnmR6KWjQLfwhFKDispw24o8M7g/nbR me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/mCDzCBE2J1jGnEhhtttIRMKkXMi1pKCAEkxu+FAim me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKF/79W6y/g26xGGPHQJwLtrmaDUb24Hd5D+WD59nzE borgs@fusu"

    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU8OZxpeEuwVYFQC1ZYOECfU8fVg0BhNIYk5tK6aNeUe4JBJezwBWIQLsxuo1YgUX1CwbP5IAAj0JyoYUzWT5H4Qyev6rj3JWvBl+kVTnJyiipRccasXD/3IuRK2GBpMcK67sUoHtgiq1kS8myuAtGh2dVeukCp196pCZC9VI0NiEmk2M6/pCiuKmaeaeyKEpkzd2wcdvqyXu3OKtq/qZyw+N8eLk8hC8wQK5lq/Syg8aZh7OV2jqe7CnRLnybybrVy3wRNI4DdoP51YEv+Q3eMlOpOdc7SGTyDPUMnTDNbBFL8u7o7xeLs/+v3neWOz/+rNkQbAoqEvN741lCozTcAxSTT8gnTOdrf+ClMFRpFMUkl3Z6JNymw0Zx2JFibhxQJWIKJq6Wh1YuDJXenIZka0sN5ut5W0KJMmCfzeyAXHy3qruYktbmUFz8iUm1ywbURZZNCmRlzESL2lE7iuTM06SxSYw4YxQHYIC4P6leMyN3hfrr4RUPtO8wJ1lALUs= kilix@epimetheus"
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDrQUmZtpxDx669VjACdtLSLcIFZ5uJl4xsj49yJW6A39IglJ4S9ViPtp/kQhGZ3jJMCCFzwDLNNJBf8XfcAtio57cucUQxtRMnY57pKH284eucCanpCq8z9KgBYtrIdzYwRVQZo2tjxdAwKS5mHSOstUnqH8CzcG0kbq7k3s31MKQhzKWXx7lZEn3osQx/aIpt0eWB/SNAS4DWhx+mdGSqO2ryBqbZKaJuH90MEWyd5MKu25+h0ELbHrkkPYOwq0EnpGqvr0mps8AjEV4iExb28E+GGtS+R7yg2tw0QWM1m4PI4XF5JRAuLqt187YvgQe9DIKTuhu2BT/EN2Os7jx9r14Pq2P/IhrR0hVloSTn2/r3geUuFYNvYiL64dkZIRxBOlC3SKut/lB3cir0FPdDkxoIuRHICrsvdSC5wFfYJfhrf0ivkEk5Jgj+lS1QlC40Xw7e0ixKILo6uiriQor02bFY4ngQHTnBLKgjNsB3K23MN80vd8V6DVZdFB+XWr8= kilia@nomos"

  ];


}
