#!/usr/bin/env bash
# univ: update niv (and generate a nice commit)

# TODO: Maybe rewrite this in Python..

# TODO libguestfs-with-appliance
# TODO create images with qemu-img and virt-format --format=qcow2 --filesystem=ext4 -a vdisk1.qcow2
# TODO Create xml by hand instead of virt-install

set -euo pipefail

# export QEMU_URI=qemu+ssh://vincent@wakasu.home/system
# virt-install --connect=${QEMU_URI} \
#              --name="ocp4-bootstrap" --vcpus=4 --ram=8192 \
#              --disk path=/var/lib/libvirt/images/ocp-bootstrap.qcow2,bus=virtio,size=120 \
#              --boot menu=on --print-xml > ocp4-bootstrap.xml
# virsh --connect=${QEMU_URI} \
    #       define --file ocp4-bootstrap.xml

HOST=${HOST:-wakasu.home}
QEMU_URI="qemu+ssh://${HOST}/system"
RSYNC_COMMAND="rsync -avzHXShPse ssh --progress"
VIRSH_COMMAND="virsh --connect=${QEMU_URI}"
NODES=(
    k8sn1
    k8sn2
    k8sn3
)

build() {
    for n in ${NODES[@]}; do
        logs=$(mktemp)
        output=$(mktemp)
        echo "Build ${n} node (logs: ${logs})…"
        nixos-generate -I nixpkgs=channel:nixos-21.05 -f qcow -c ./systems/hosts/${n}.nix 2>${logs} 1>${output}
        echo "Resize ${n} image"
        qemu-img create -f qcow2 -o preallocation=metadata ${n}.qcow2 40G
        virt-resize --expand /dev/vda1 $(cat ${output} | tr -d '\n') ${n}.qcow2
        echo "Syncthing image to ${HOST}…"
        ${RSYNC_COMMAND} ${n}.qcow2 root@${HOST}:/var/lib/libvirt/images/${n}.qcow2
        echo "Remove ${n} (local) image"
        rm -f ${n}.qcow2
    done
}

delete() {
    for n in ${NODES[@]}; do
        echo "Delete ${n} node…"
        ${VIRSH_COMMAND} list | grep ${n} && {
            ${VIRSH_COMMAND} destroy ${n}
        } || {
            echo "skipping, not present…"
        }
        ${VIRSH_COMMAND} undefine ${n} --remove-all-storage || echo "Failed to erase.. might not exists"
    done
}

# Bootstrap the cluster, assuming images are built and synced
bootstrap() {
    echo "Bootstrap k8s cluster on ${HOST}"
    k8sn1_mac="52:54:00:dd:a3:30"
    k8sn2_mac="52:54:00:dd:a3:31"
    k8sn3_mac="52:54:00:dd:a3:32"
    folder=$(mktemp -d)
    for n in ${NODES[@]}; do
        mac_addr=${n}_mac
        virt-install --connect=${QEMU_URI} \
                     --name="${n}" --vcpus=4 --ram=8192 \
                     --network bridge=br1,mac.address=${!mac_addr} \
                     --disk path=/var/lib/libvirt/images/${n}.qcow2,bus=virtio,size=10 \
                     --disk path=/var/lib/libvirt/images/${n}-data.qcow2,bus=virtio,size=40 \
                     --print-xml > ${folder}/${n}.xml
        echo "Node ${n} : ${folder}/${n}.xml"
        ${VIRSH_COMMAND} define --file ${folder}/${n}.xml
    done
    # Start the nodes
    for n in ${NODES[@]}; do
        ${VIRSH_COMMAND} start ${n}
    done
    # Wait for.. long time..
    # Not sure how to ensure k8s is running on the master
    token=$(ssh root@k8sn1.home cat /var/lib/kubernetes/secrets/apitoken.secret)
    echo $token | ssh root@k8sn2.home nixos-kubernetes-node-join
    echo $token | ssh root@k8sn3.home nixos-kubernetes-node-join
    mkdir -p $HOME/.kube
    # TODO: Copy cluster-admin configuration and sed the certs
    scp root@k8sn1.home:/etc/kubernetes/cluster-admin.kubeconfig $HOME/home.cluster-admin.config
}

status() {
    echo "TBD: display the status of the cluster"
}

main() {
    set +u
    ARG=$1
    set -u
    case ${ARG} in
        "build")
            build
            ;;
        "delete")
            delete
            ;;
        "bootstrap")
            bootstrap
            ;;
        "status")
            status
            ;;
        *)
            echo "No such subcommand"
            exit 1
            ;;
    esac
}

main $@
