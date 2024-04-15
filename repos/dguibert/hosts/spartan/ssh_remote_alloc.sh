#!/usr/bin/env bash

set -xue -o pipefail

machine_file=${1:-/tmp/nix--home_nfs-bguibertd-machines}

while IFS= read -r line; do
  echo ": $line"

  case "$line" in
#salloc: Granted job allocation 262359
#salloc: Waiting for resource configuration
#salloc: Nodes spartan506 are ready for job

    *Nodes*)
      NODE=$(echo -e "$line" | grep "Nodes " | awk '{ print $3 }')
      echo "ssh://$NODE x86_64-linux - 16 2 benchmark,big-parallel,recursive-nix" >> $machine_file
      ;;
    *Granted*) # job allocation*)
      JOB_ID=$(echo -e "$line" | grep "Granted job allocation" | awk '{print $NF}')

function cancel_job() {
    sed -i "/$NODE/d" $machine_file
    ssh -T spartan scancel $JOB_ID
}
trap cancel_job EXIT
    ;;
  esac
done < <(ssh -T -f -o PubkeyAuthentication=yes spartan salloc -N1 -C CSL -A pro_2020_esiwace2 -J build -- srun -n1 -N1 --mem-per-cpu=0 --preserve-env --cpu-bind=no "sleep 1d"   2>&1)

#echo "To cancel:"
#echo "ssh -T -f -o PubkeyAuthentication=yes spartan $JOB_ID"
#echo "ssh $NODE -O exit"
#wait $pid
