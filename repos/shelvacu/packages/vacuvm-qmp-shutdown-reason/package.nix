{ makeVacuPythonScript }:
# Ask a running QEMU, over QMP, why it shut down — a guest reboot and a guest
# poweroff both make QEMU exit 0, and only the SHUTDOWN event tells them apart.
# Used by the qemu-vm module to decide whether to restart a VM. See main.py.
makeVacuPythonScript {
  name = "vacuvm-qmp-shutdown-reason";
  libraries = [ "qemu-qmp" ];
  src = ./main.py;
}
