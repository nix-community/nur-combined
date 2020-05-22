{ pkgs
, stream
, date ? "20181216"
, admin_scripts_dir
, scheduler
}:
with pkgs; let

  jobs = recurseIntoAttrs (rec {
    bench-helpers = import ./bench-helpers.nix { inherit pkgs; };

    scheduler_local = import ./scheduler-local.nix { inherit pkgs date; };
    scheduler_slurm = import ./scheduler-slurm.nix { inherit pkgs date; };

    inherit scheduler;

    vnc = import ./vnc.nix { inherit pkgs scheduler; };

    node_check = lib.genAttrs (lib.mapAttrsToList (n: v: n) scheduler.partitions)
      (partition: lib.genAttrs scheduler.partitions."${partition}".nodeset
        (node:
          (scheduler.runJob { name="node-check-${node}-${date}";
             options = default_sbatch_genji // {
               #partition="${partitions.${partition}.name}";
               partition="all"; # to get the same check across partitions
               nodelist="${node}";
               time="00:03:00";
               exclusive=true;
               #ntasks="1";
             };
             buildInputs = [ envs._intel19._avx512.stream time ];
             script = ''
               ${figlet}/bin/figlet "Node Check"
               set -xuef -o pipefail
               set +x
               CONF_FILE=/etc/node-perf.conf
               FAILED='\033[0;31mFAILED\033[0m' # 31 red
               PASSED='\033[0;32mPASSED\033[0m' # 32 green
               INFO='\033[0;32mINFO\033[0m' # 32 green
               WARNED='\033[0;33mWARNED\033[0m' # 33 yellow
               OK=0
               echo -e "CHECK NODE : $HOSTNAME"
               if [ -e $CONF_FILE ]; then
                 exists_=true
                 echo -e "$CONF_FILE exists ... $PASSED"
               else
                 exists_=false
                 echo -e "$CONF_FILE does not exist ... $WARNED"
               fi
               echo -e "############################################################
               # CPU check
               ############################################################"
               cpu_type=$(/usr/bin/lscpu | grep "^Model name:" | awk -F: '{print $2 }')
               cpu_type=$(echo -e $cpu_type)
               if $exists_; then
                 CPU_TYPE=$( cat $CONF_FILE | grep CPU_TYPE | awk -F: '{print $2 }' )
                 if [ "$CPU_TYPE" != "$cpu_type" ]; then
                   echo -e "Cpu type intended: "$CPU_TYPE" != "$cpu_type" ... $FAILED"
                 else
                   echo -e "Cpu type: $cpu_type ... $PASSED"
                 fi
               else
                 echo -e "Cpu type: $cpu_type ... $INFO"
               fi

               #### CPU FREQUENCY
               cpu_freq=$(/usr/bin/lscpu | grep "^CPU MHz:"| awk -F: '{print $2 }')
               cpu_freq=$(echo -e $cpu_freq)
               if $exists_; then
                 CPU_FREQ=$( cat $CONF_FILE | grep "^CPU_FREQ" | awk -F: '{print $2 }' )
                 var=$(awk 'BEGIN{ print "'$cpu_freq'" != "'$CPU_FREQ'" }')
                 if [ $var -eq 1 ]; then
                   echo -e "Cpu frequency intended: "$CPU_FREQ" != "$cpu_freq" ... $FAILED"
                 else
                   echo -e "Cpu frequency: $cpu_freq MHz ... $PASSED"
                 fi
               else
                 echo -e "Cpu frequency: $cpu_freq MHz ... $INFO"
               fi


               ### NB LOGICAL CORE
               nb_core=$(/usr/bin/lscpu | grep "^CPU(s):" | awk -F: '{print $2 }')
               nb_core=$(echo -e $nb_core)
               threads=$(/usr/bin/lscpu | grep "^Thread(s) per core:" | awk -F: '{print $2 }')
               threads=$(echo -e $threads)
               Physic=$((nb_core/threads)) #NB OF PHYSICAL CORES
               if $exists_; then
                 NB_CORE=$( cat $CONF_FILE | grep "^CPU_NB" | awk -F: '{print $2 }' )
                 if [ $nb_core -ne $NB_CORE ]; then
                   echo -e "Number of logical cores intended: $NB_CORE != $nb_core ... $FAILED"
                 else
                   echo -e "Number of logical cores: ($Physic c * $threads t): "$nb_core" ... $PASSED"
                 fi
               else
                 echo -e "Number of logical cores: ($Physic c * $threads t): "$nb_core" ... $INFO"
               fi


               echo -e "############################################################
               # Memory check
               ############################################################"

               #### MEMORY FREQ
               MEM_SPEED=$(/usr/bin/sudo ${admin_scripts_dir}/dmidecode_t_memory.sh | grep -i "Configured Clock Speed" | grep MHz |  awk -F: '{ print $2 }' | uniq)
               MEM_SPEED=$(echo -e $MEM_SPEED)
               if $exists_; then
                 MEM_FREQ=$( cat $CONF_FILE | grep "^MEM_FREQ" | awk -F: '{print $2 }' )
                 if [ "$MEM_SPEED" != "$MEM_FREQ" ]; then
                   echo -e "Memory frequency intended: $MEM_FREQ != $MEM_SPEED ... $FAILED"
                 else
                   echo -e "Memory frequency: $MEM_SPEED ... $PASSED"
                 fi
               else
                 echo -e "Memory frequency: $MEM_SPEED ... $INFO"
               fi

               ## MEM CONF SIZE
               dimm_size=$(/usr/bin/sudo ${admin_scripts_dir}/dmidecode_t_memory.sh | grep -i size | grep "\(MB\|GB\)" | awk '{ print $2 }' | uniq)
               dimm_nb=$(/usr/bin/sudo ${admin_scripts_dir}/dmidecode_t_memory.sh | grep -i size | grep "\(MB\|GB\)" | awk '{ print $2 }' | wc -l)
               if /usr/bin/sudo ${admin_scripts_dir}/dmidecode_t_memory.sh | grep -i size | grep MB >/dev/null; then
                 sum=$(((dimm_size * dimm_nb)/1024))
               else
                 sum=$((dimm_size * dimm_nb))
               fi

               if $exists_; then
                 MEM_SIZE=$( cat $CONF_FILE | grep "^MEM_SIZE" | awk -F: '{print $2 }' )
                 if [ "$sum" != "$MEM_SIZE" ]; then
                   echo -e "Memory size intended: $MEM_SIZE != $sum ... $FAILED}"
                 else
                   echo -e "Memory size ($dimm_size * $dimm_nb): $sum Go ... $PASSED"
                 fi
               else
                 echo -e "Memory size ($dimm_size * $dimm_nb): $sum Go ... $INFO"
               fi

               echo -e "############################################################
               # Benchmarks check
               ############################################################"
               ##STREAM
               a=$( stream_c |grep Triad: )
               comp=$( echo -e $a | awk '{ print $2 }' )
               if $exists_; then
                 STREAM_RES=$( cat $CONF_FILE | grep "^STREAM" | awk -F: '{print $2 }' )
                 var=$(bc <<< " $comp < $STREAM_RES " )
                 if [ $var -eq 0 ]; then
                   echo -e "STREAM: $comp MB/s ... $PASSED"
                 else
                   echo -e "STREAM intented: $STREAM_RES != $comp MB/s ... $FAILED"
                 fi
               else
                 echo -e "STREAM: $comp MB/s ... $INFO"
               fi

             '';}
             )
           ));
    #summary_bench = runCommand "test" { } ''
    #  ${lib.concatMapStrings (node: "echo ${node}: state ${(builtins.getAttr node nodes).State }\n")
    #    (partitions.SKL-20c_edr-ib2_192gb_2666.NodeSet)
    #  }
    #'';

    default_sbatch_genji = {
      job-name="bash";
      nodes="1";
      partition=scheduler_slurm.partitions.SKL-20c_edr-ib2_192gb_2666.name;
      time="00:03:00";
      exclusive=true;
      verbose=true;
      no-requeue=true;
      #ntasks-per-node="8";
      #cpus-per-task="5";
      #threads-per-core="1";
    };
    inherit (scheduler) runJob;

    #job1 = runJob { name="test";
    #  options = default_sbatch_genji // {
    #    nodes="1";
    #  };
    #  script = ''
    #    ${figlet}/bin/figlet "srun"
    #    export TIME="hostname timing : %e elapsed %U user %S system - %M Kbytes memory max. %W swapped times"
    #    /usr/bin/time /usr/bin/srun /usr/bin/sleep 60
    #  '';
    #};
  });
in jobs
