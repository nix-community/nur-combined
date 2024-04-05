{ secretsDir, ... }:
{
	programs.ssh = {
		enable = true;
		matchBlocks = {
      "*" = {
				identityFile = "${secretsDir}/private-key";
      };
			"github.com" = {
				hostname = "github.com";
			};
      sepp = {
        user = "seb";
      };
      here = {
        port = 8888;
        hostname = "127.0.0.1";
        user = "me";
      };
      rpi = {
        port = 49388;
        user = "me";
      };
      files = {
        port = 49388;
        user = "files";
      };
      rpis = {
        hostname = "rpi";
        port = 49388;
        user = "server";
      };
      phone = {
        user = "u0_a345";
        port = 8022;
      };
      tab = {
        user = "nix-on-droid";
        port = 8022;
      };
      acern = {
        user = "me";
        port = 2222;
      };
			hpm = {
				user = "me";
			};

			fusus = {
				hostname = "fusu";
				user = "server";
			};

		  fusu = {
				hostname = "fusu";
				user = "me";
			};

			ocih = {
				hostname = "152.67.70.13";
				user = "ubuntu";
			};
			ocib = {
				hostname = "140.238.213.48";
				user = "ubuntu";
			};
      hec-builder = {
				hostname = "10.5.5.56";
				user = "root";
      };
      storage = {
				hostname = "10.5.5.50";
				user = "root";
      };
		};
	};

   home.file.".ssh/known_hosts".force = true;
   home.file.".ssh/known_hosts".text = ''
      hpm ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+FpaNOf+ao6RCa6e43vAHFcQZTGu45rIqAG3Vx0/M8
      lush ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNQClF4DQhO1jSkVWhusp1wfxadSsDclg0TbFGbR+Gy
      github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      rpi ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX+6B6Axx7AqgCm1H1rrou/3yOLeOLcTd8s0In0mOIY
      files ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX+6B6Axx7AqgCm1H1rrou/3yOLeOLcTd8s0In0mOIY
      phone ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHxg0HKtGAkwymll8r17d9cXdt40dJgRkSAzB699pWke+edne4Ildcnbde2yle01nEL7GOg92vh5t1sh6vkCzJQ=
      uwu ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6H4kcLXH5hvXN8Ablcfo4q2MwdvVBiAdYWlc4qUiCj
      [phone]:8022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN30DqIE7AMYBoKnmbDw+U01LAEC25JZjIXB+T76LBp9
      [phone]:8022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSWFzU8GrAJD/CKJby8IbUzLtbXxwYBF+QQzSRIlbx5kCS2MQjjNtLjAMdt2c8z0O2+qX9abEZXmtYfYlHCo2nCFOhhkjuzT7t6lb14wjAK2HBBWOsh2Y1WSK35FzKtWJvmYcu1uWdDZrvu44PoFITJhCAoZG6QaGlhXVGk1lpasP1qA1/guX/LJYVUGww7oSjQeeAxjKFxrLK01iD1aS60IxIHZIT4yKe//YhppC8LkJc0OnRIzmCMdNIHNXIsg0dL/8to5vA85hqJlTJAZ9qhw542Ul5C34F2z69h4hf3eslIqvVL/tci86jgX4eYiVsUZ81jFtGN3As2RpcOLz8mrC1qZgHTLqix6PaNRrQeRcfvMIH0VOiyzAFEzBI/v0wj1zthRHOg+xKfAq1hKhXarJRYw0c0wmgPUoAOUQGwoF2JGIss7D7ulKTUd7ALn8fdS8+CboFSQ709OA44pSEsAl6IfXT/gh4zHwubfT3mRbla8iQAXYD/nKF5xPQ+Jc=
      [phone]:8022 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEN+gaX1uwr5oY98hJYGWwBQEEDpmbJsKLY7vIfWRQo02IH36ZC0p14GOnfPLtXuHz8AoNUp7UYyNu8oXxuU/fE=
    [tab]:8022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCWnKy5TnPukGMkxYGLjs4Tpu/v3x8JfxaU7dcaAcp3KhxtUDPjdSQLGEIS08L781nGpIJZRdy+jNqKiolQRRTuy7eQaZnCO+ddYQldW2OpqVGbOjS/7T7cHy+aHFJdPiltdgagfPIPColYCGCCoMi3wN7VkR49MAYOr1a0YIlfh1y0PgCbGqkYCPKO90woXPYxI+v5trYHaqNDz9O5ug7k93AHQuTQroqfyzM9vhcg8z42EpDzTs+ypdgXJYOuc4ZbH1mWkou+1SPEZxMSoNUipmwkjQ5GCEwPIpSgRoRHh2WnXU8TmLLDVteJ7zUJlLR8p93rgmp2Uo1gePCsQNiqd4XrmdgdNypUifUE5M7V5LOcuCtZJfX0XZHoo+cvVKgQqpz8MIJAFOJzCXt39/gxcytDwSbN+B4oh9CR4kGGCST/griKpR3rl+PKDap1rpGZYBlPv0ss6RNZTVnIKuv6MaFXLmmrkpaKiFX3Bmze6820BO/LXz5qoLbL8dIf0s=
    [tab]:8022 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKY8+fJoEuAh0KlB9/g40ImJVcFEuksckgCA5BNK1gdhGsRBkN9LE16Wu07bzVbtBhdYoGDdflI9Hr6l1Y6gu0I=
    [tab]:8022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPVAyWNCCzQSOzeYibuXNPExD7YKcNczvJfc44a3zeo
      [tab]:8022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdwFZf3IRa4YZyrNseofTRIDbkmdMiIXa3Gxs7wFzZN+ICwXeipfqV1Lh9C1sI4YnRIqfZlCSU+SE2dqVoQB6Uj64cdLrdslHYvgsR9PY3vVtrYypGfE1XTkLvD516x4mFofo22A9j8fK95fcMwpWLtNnv9SVBIT3V+4fUlbRCngdJ1V2cOd41JIwBrIxmRJ6X5v/SEqajmnVneqEmsqGgGA7JBJBCMSz5wwmZzWrTpzwj4SAD5b1z/R12DZfFHmgJCZYcMbjDgUiD5khsOwCCflH8DtO41PkOZRqDlpPPT9al7qhhESwxE6w5gIvaVh6HJljSCNw9OCQWONotv3gF9tVs6sZXsWxRZ2R0oIeA3rnM+mZxEtxElc2MKLVlsQ9SM2Xcr3J4Y43cWm7m03cDOz+iZecxs2qKAgn5Au72fudapDAtiCuYjKlMGEgbWX3CmxL0n/Uo32yfTRXnEHWMzXezmdGsuHUzk/sHTL8z5RVyzIBNl2HGlhldFbATuwRxXyBW9JIuEll+rW9Jm0MvpT3KoD/Q5aXDVH+21l6SSNBcjvZu00WNiYDD+gFR4BlewobtacGNOR4ErjxVZ10d8p6S5smadmo/RmbjhrVJK8EzigJPsVxEEjtuVq+jAQCvLTZCpEyDF/cBv60vIu4CyZkoAq1UaL64m7nIhR/8Yw==
   '';
}
