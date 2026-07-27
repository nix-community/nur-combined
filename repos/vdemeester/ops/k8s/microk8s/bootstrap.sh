#!/usr/bin/env bash
set -euxo pipefail
QEMU_URI=${QEMU_URI:-qemu+ssh://wakasu.home/system}
declare -A addrs=( ["ubnt1"]="30" ["ubnt2"]="31")

token="$(pwgen -1 32)"

bootstrap() {
    machine=$1
    virt-install --connect="${QEMU_URI}" \
      --name="${machine}" --vcpus=4 --ram=4192 \
      --disk path=/var/lib/libvirt/images/${machine}.qcow2,bus=virtio,size=120 \
      --network bridge=br1,mac.address=52:54:00:dd:a3:${addrs[${machine}]} \
      --os-variant ubuntu20.04 \
      --location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/' \
      --initrd-inject ${machine}/preseed.cfg \
      --video=vga \
      --wait=-1 \
      --extra-args 'ks=file:/preseed.cfg /console=ttyS0,115200n8 serial'
#      --graphics none \
#      --console pty,target_type=serial \
#      --extra-args 'ks=file:/preseed.cfg /console=ttyS0,115200n8 serial'
}

configure-ubnt1() {
    ssh -o "StrictHostKeyChecking=no" -t vincent@192.168.1.130 sudo snap install microk8s --classic --channel=1.22
    ssh -t root@192.168.1.130 microk8s status --wait-ready
    ssh -t root@192.168.1.130 usermod -a -G microk8s vincent
    ssh -t root@192.168.1.130 microk8s enable dns ingress storage registry rbac
    ssh -t root@192.168.1.130 mkdir -p /root/.kube
    # ssh -t root@192.168.1.130 microk8s config > /root/.kube/config.microk8s
    # FIXME: Parse the output to get the full url to join
    ssh -t root@192.168.1.130 microk8s add-node --token-ttl=-1 --token=${token}
}

configure-ubnt2() {
    ssh -o "StrictHostKeyChecking=no" -t root@192.168.1.131 sudo snap install microk8s --classic --channel=1.22
    ssh -t root@192.168.1.130 microk8s status --wait-ready
    ssh -t root@192.168.1.130 usermod -a -G microk8s vincent
    ssh -t root@192.168.1.131 microk8s join 192.168.1.130:250000/${token}
}

for m in ubnt*; do
    set +e
    virsh --connect="${QEMU_URI}" list | grep $m
    if [[ $? -gt 0 ]]; then
        set -e
        bootstrap $m
        echo "bootstrap machine $m"
        sleep 60
        configure-$m
    fi
done
