$ ./result/bin/cudominercli 
Pkg: Error reading from file.

$ strace ./result/bin/cudominercli 2>&1 | grep open
...
openat(AT_FDCWD, "/sys/fs/cgroup/memory/memory.limit_in_bytes", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
...

$ ls /sys/fs/cgroup/memory.* | cat
/sys/fs/cgroup/memory.numa_stat
/sys/fs/cgroup/memory.pressure
/sys/fs/cgroup/memory.reclaim
/sys/fs/cgroup/memory.stat



# https://stackoverflow.com/questions/65646317/sys-fs-cgroup-memory-memory-limit-in-bytes-not-present-in-fedora-33

$ findmnt /sys/fs/cgroup
TARGET         SOURCE  FSTYPE  OPTIONS
/sys/fs/cgroup cgroup2 cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot

The issue is related to new cgroup v2. To resolve this, revert cgroup to v1:

sudo sed -i '/^GRUB_CMDLINE_LINUX/ s/"$/ systemd.unified_cgroup_hierarchy=0"/' /etc/default/grub

and reboot.

After this /sys/fs/cgroup/memory/memory.limit_in_bytes will be present.
