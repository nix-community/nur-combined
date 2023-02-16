{ self, system, ... }:
let region = "ap-southeast";
in {
  variable.LINODE_TOKEN = {
    type = "string";
    description = "Linode API token";
    nullable = false;
    sensitive = true;
  };

  terraform.required_providers.linode.source = "linode/linode";

  provider.linode.token = "\${ var.LINODE_TOKEN }";

  data.linode_images.nixos-base-image = {
    filter = {
      name = "label";
      values = [ "nixos-base" ];
    };
  };

  data.linode_stackscripts.ditto-transform = {
    filter = {
      name = "label";
      values = [ "ditto-transform" ];
    };
  };

  resource.linode_instance.diglett = {
    inherit region;

    label = "diglett";
    group = "nixos";
    tags = [ "nixos" ];
    type = "g6-nanode-1";
    # This currently seems to both error with a message that is unrelated as 
    # well as not actually work with a stack script :sadpanda:
    # stackscript_id =
    #   "\${data.linode_stackscripts.ditto-transform.stackscripts.0.id}";
    # stackscript_data.target = "diglett";
  };

  resource.linode_instance_disk.boot = {
    label = "boot";
    linode_id = "\${linode_instance.diglett.id}";
    size = 15000;
    image = "\${data.linode_images.nixos-base-image.images.0.id}";
  };

  resource.linode_instance_disk.swap = {
    label = "swap";
    linode_id = "\${linode_instance.diglett.id}";
    size = 512;
    filesystem = "swap";
  };

  resource.linode_instance_config.diglett-config = {
    linode_id = "\${linode_instance.diglett.id}";
    label = "boot_config";
    booted = true;
    kernel = "linode/grub2";

    helpers = {
      devtmpfs_automount = false;
      distro = false;
      modules_dep = false;
      network = false;
      updatedb_disabled = false;
    };

    root_device = "/dev/sda";

    devices = {
      sda.disk_id = "\${linode_instance_disk.boot.id}";
      sdb.disk_id = "\${linode_instance_disk.swap.id}";
    };

    interface = [{ purpose = "public"; }];
  };
}
