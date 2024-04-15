#!/usr/bin/env bash

set -ue -o pipefail

usage()
{
 echo "Usage : ./create_mask.sh <nb cores per socket> <nb socket> <ht on or off>"
 exit
}
if [ ! $3 ];then
  usage
fi

diviseur() {
  local number=$1
  local div
  local compt

  if [ $number -eq 1 ] ;then
    echo '1  1  '
  else
    compt=0
    div=$(( $number/2 ))
    div=$number
    while [ $div -ge 1 ] ; do
       val=$(( $number / $div ))
       val=$(( $val * $div))
       if [ $val -eq $number ] ; then
          echo $div  $(( $number / $div ))
          compt=$(( compt + 1 ))
       fi
       div=$(( $div -1 ))
    done

  fi
}

socket_per_node=$2
cores_per_socket=$1
echo "#Mask creation for a node with "$socket_per_node" sockets and "$cores_per_socket" cores per sockets"
if [ $3 == "on" ];then
	threads_per_core=2
	echo "#Hyperthreading is enabled"
	echo "#To create this mask we suppose that the cpu numbering is as followed :"
	echo "#socket0 socket1 socket0 socket1"

else
	threads_per_core=1
	echo "#Hyperthreading is disabled"
fi

echo "export OMP_PROC_BIND=true "
echo 'export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}'
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}

diviseur $(( socket_per_node*cores_per_socket*threads_per_core )) | while read PPN OMP_NUM_THREADS; do
  MASK_CPU=
  if [ $OMP_NUM_THREADS -eq 1 ]; then
  	step=$OMP_NUM_THREADS
  else
  	step=$OMP_NUM_THREADS/${threads_per_core}
  fi
  for (( cpu=0; cpu < ${PPN}*$step; cpu+=step)); do
    bin=0
    for (( thread=cpu; thread < cpu+step; thread++)); do
      # compute the binary of the core id and its virtual thread ID if HT=on
      bin=$(bc <<< "(2^$thread) + (${threads_per_core}-1)*( 2^($thread+${socket_per_node}*${cores_per_socket})) + $bin")
    done
    MASK_CPU+="0x$(bc <<< "obase=16;$bin"),"
  done
  MASK_CPU=${MASK_CPU%%,} # remove last ,
  SRUN_OPTIONS=--cpu_bind=mask_cpu:$MASK_CPU,verbose

  echo "if [  \$OMP_NUM_THREADS == $OMP_NUM_THREADS ]; then"
  echo "  echo OMP_NUM_THREADS=$OMP_NUM_THREADS and PPN=$PPN "
  echo "  export S_LAUNCHER_OPTIONS=\"$SRUN_OPTIONS\""
  echo "# for Intel MPI"
  echo "  export I_MPI_PIN_DOMAIN=[$MASK_CPU]"
  echo "fi"
done
