{ pkgs }:
with pkgs;
rec {
  #admin_scripts_dir = "/scratch_gpfs/script/admin";
  admin_scripts_dir = "/home_nfs/script/admin";
  ## pkgs/build-support/trivial-builders.nix
  #runCommand name env buildCommand
  #makeSetupHook = { name ? "hook", deps ? [], substitutions ? {} }: script:
  # TODO consider stringAfter to fill the whole job file
  makeBenchHook = { name ? "bench-hook", type ? "jobSetup", deps ? [], substitutions ? {} }@args: script:
    makeSetupHook (removeAttrs args [ "type" ]) (writeScript "${name}.sh" ''
      ${type}Hooks+=(_${name})
      _${name}() {
        set -xue -o pipefail
        ${script}
        set +ux
      }
    '');
  benchCheckFileSystems = { home_root, scratch_root }: makeBenchHook { name =
      "benchCheckFileSystems"; deps = [ figlet pythonPackages.clustershell ];} ''
        figlet "Check filesystems"
        export NODES_WITH_SCRATCH=`clush -w "$SLURM_NODELIST" -f 200 'df' 2>/dev/null | grep " ${scratch_root}"    | wc -l`
        export NODES_WITH_HOME=`   clush -w "$SLURM_NODELIST" -f 200 'df' 2>/dev/null | grep " ${home_root}$" | wc -l`

        if [ "$SLURM_NNODES" != $NODES_WITH_SCRATCH  ]
        then
          echo "on some nodes among $SLURM_NNODES, scratch=${scratch_root} is not mounted ($NODES_WITH_SCRATCH only)."; exit 2
        fi

        if [ "$SLURM_NNODES" != $NODES_WITH_HOME  ]
        then
          echo "on some nodes among $SLURM_NNODES, home=${home_root} is not mounted ($NODES_WITH_HOME only)."; exit 3
        fi

        # ............. lustre & OSTs:
        if echo ${scratch_root} | grep lustre > /dev/null; then
          export LUSTRE_vs_GPFS="lustre"
          export INACTIF=`clush  -w "$SLURM_NODELIST" -f 200  ' lfs df -h | grep "inactive device"  ' 2> /dev/null  | wc -l `
          if [[ "$INACTIF" != "0" ]] ;then
            /bin/echo -e "\n\n exit: some nodes among $SLURM_NODELIST have insactive OSTs.\n\n"; exit 4
          fi
        else
          export LUSTRE_vs_GPFS="gpfs"
        fi
  '';
  jobScratchDir = { scratch ? "/scratch_gpfs/bguibertd/s", drv }: let
      basename = baseNameOf (builtins.toPath drv);
    in "${scratch}/${builtins.substring 0 12 basename}";

  benchInScratchHook = { scratch }: makeBenchHook { name = "benchInScratch"; } ''
        figlet "Setup scratch"
        job_out=$(basename $out)
        export SCRATCH=${scratch}/''${job_out:0:12}
        mkdir -p $SCRATCH
        cd $SCRATCH
        ln -s $out $SCRATCH/drv
        mkdir -p $out/nix-support
        echo $PWD > $out/nix-support/scratch_dir
  '';
  benchRemoveScratchHook = makeBenchHook { name = "benchRemoveScratch";  type = "jobDone"; } ''
        figlet "Remove scratch"
        rm -rf $SCRATCH
  '';

  benchPrintEnvironmentHook = makeBenchHook { name = "benchPrintEnvironment"; deps = [ figlet ]; } ''
        # dropcache (prologs/epilogs slurm should contain drop cache):
        clush -bw "$SLURM_NODELIST" "${admin_scripts_dir}/dropcache_in_slurm" 2>/dev/null

        # .............  save informations about the configuration:

        figlet Environment

        figlet "printenv"                                                                  | tee    env.txt
        printenv |sort                                                                2>&1 | tee -a env.txt
        figlet "ulimit"                                                               2>&1 | tee -a env.txt
        ulimit -a                                                                     2>&1 | tee -a env.txt
        figlet "mpirun"                                                               2>&1 | tee -a env.txt
        command -v mpirun || true                                                     2>&1 | tee -a env.txt
        figlet "scontrol"                                                             2>&1 | tee -a env.txt
        /usr/bin/scontrol -dd show job $SLURM_JOBID                                   2>&1 | tee -a env.txt
        figlet "interconnect"                                                         2>&1 | tee -a env.txt
        /usr/sbin/ibstatus                                                            2>&1 | tee -a env.txt
        clush -bw "$SLURM_NODELIST" '/usr/sbin/ibstatus | grep rate'                         | tee -a env.txt 2>/dev/null
        if [[ -f /etc/topology.conf ]]; then
          figlet "topology"                                                           2>&1 | tee -a env.txt
          cat /etc/slurm/topology.conf                                                2>&1 | tee -a env.txt
        fi
        figlet "SLURM"                                                                2>&1 | tee -a env.txt
        /usr/bin/sbatch -V                                                            2>&1 | tee -a env.txt
        cat /etc/slurm/slurm.conf                                                     2>&1 | tee -a env.txt
        #figlet "INPUT"                                                               2>&1 | tee -a env.txt
        #echo $DATA                                                                   2>&1 | tee -a env.txt
        #lfs getstripe $DATA                                                          2>&1 | tee -a env.txt
        figlet "TMPDIR"                                                               2>&1 | tee -a env.txt
        echo $TMPDIR                                                                  2>&1 | tee -a env.txt
        if [[ $LUSTRE_vs_GPFS = "lustre" ]]; then
          lfs getstripe $TMPDIR                                                       2>&1 | tee -a env.txt
          echo "Who is using lustre:"                                                 2>&1 | tee -a env.txt
          #sqlustre | grep $SCRATCH                                                   2>&1 | tee -a env.txt
        fi
        figlet "NUMA"                                                                 2>&1 | tee -a env.txt
        clush -bw "$SLURM_NODELIST" 'cat /proc/sys/kernel/numa_balancing'                    | tee -a env.txt 2>/dev/null
        figlet "Hugepage"                                                             2>&1 | tee -a env.txt
        clush -bw "$SLURM_NODELIST" 'cat /sys/kernel/mm/transparent_hugepage/enabled'        | tee -a env.txt 2>/dev/null
        figlet "zone_reclaim_mode"                                                         | tee -a env.txt
        clush -bw "$SLURM_NODELIST" -f 200 '/sbin/sysctl -e vm.zone_reclaim_mode'            | tee -a env.txt 2>/dev/null
        figlet "uptime"                                                                    | tee -a env.txt
        clush -bw "$SLURM_NODELIST" -f 200 '/usr/bin/uptime'                                 | tee -a env.txt 2>/dev/null
        figlet "free"                                                                      | tee -a env.txt
        clush -bw "$SLURM_NODELIST" -f 200 '/usr/bin/free -g'                                | tee -a env.txt 2>/dev/null
        figlet "frequency"                                                                 | tee -a env.txt
        case ''${FREQUENCY_MODE:-} in
          "userspace")   echo "frequency set to $FGHZ"                                     | tee -a env.txt ;;
          "performance") echo "performance mode; turbo used when available"                | tee -a env.txt ;;
          "") SYS_CPU=/sys/devices/system/cpu
              FREQUENCY_DEFAULT=$(clush -bw "$SLURM_NODELIST" "sort -u $SYS_CPU/cpu*/cpufreq/scaling_cur_freq" 2>/dev/null | tail -1)
              FREQUENCY_MODE=$(clush -bw "$SLURM_NODELIST" "cat $SYS_CPU/cpu0/cpufreq/scaling_governor" 2>/dev/null &>/dev/null)
              echo "defaut frequency: $FREQUENCY_DEFAULT"                                  | tee -a env.txt
              echo "gouvernor frequency: $FREQUENCY_MODE"                                  | tee -a env.txt ;;
        esac
        # contents of the /proc/modules, showing what kernel modules are currently loaded
        figlet "lsmod"                                                                     | tee -a env.txt
        /usr/sbin/lsmod                                                                    | tee -a env.txt
  '';

}
