{ ... }: {
  config = {
    environment.dotd."nix/machines".enable = true;
    nix.distributedBuilds = true;
    nix.buildMachines = [
      # {
      #   hostName = "192.168.100.52"; # pc dos testes
      #   sshUser = "lucasew";
      #   system = "x86_64-linux";
      #   sshKey = "/etc/ssh/ssh_host_ed25519_key";
      #   maxJobs = 4;
      #   speedFactor = 2;
      #   supportedFeatures = [ "big-parallel" "kvm" ];
      # }
      # {
      #   hostName = "192.168.69.1"; # whiterun
      #   sshUser = "lucasew";
      #   system = "x86_64-linux";
      #   sshKey = "/etc/ssh/ssh_host_ed25519_key";
      #   maxJobs = 12;
      #   speedFactor = 4;
      #   supportedFeatures = [ "big-parallel" "kvm" ];
      # }
    ];
    # disabled by default, ln it to enable
    environment.etc."nix/machines.d/.00-whiterun".text = ''
      ssh-ng://lucasew@192.168.69.1 x86_64-linux /etc/ssh/ssh_host_ed25519_key 12 12 big-parallel,kvm,nixos-test,benchmark
    '';
    environment.etc."nix/machines.d/.00-genetsec".text = ''
      ssh-ng://lucasew@192.168.0.101 x86_64-linux /etc/ssh/ssh_host_ed25519_key 4 4 big-parallel,kvm,nixos-test,benchmark
      ssh-ng://lucasew@192.168.0.102 x86_64-linux /etc/ssh/ssh_host_ed25519_key 4 4 big-parallel,kvm,nixos-test,benchmark
      ssh-ng://lucasew@192.168.0.103 x86_64-linux /etc/ssh/ssh_host_ed25519_key4 4 big-parallel,kvm,nixos-test,benchmark
    '';
  };

}
