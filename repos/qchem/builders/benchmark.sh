#!/usr/bin/env bash


showHelp () {
  echo
  echo "Usage: $(basename $0) <action>"
  echo
  echo "actions:"
  echo " build     build the benchmark script"
  echo " run       run all benchmarks"
  echo " analyze   analyze results"

}

if [ -z "$1" ]; then
  showHelp
  exit
fi


case $1 in
  "build")
    shift
    if [ -z "$1" ]; then
      echo
      echo "Usage: $(basename $0) build <configfile> [extra parameters for nix-build]"
      echo ""
      exit
    fi

    config=$1
    shift
    nix-build -A benchmarks -o benchfiles --arg config $config $@
  ;;

  "run")
    shift
    if [ -z "$1" ]; then
      benchmarkSet=benchfiles/bench-*
    else
      benchmarkSet=$1
    fi

    echo $benchmarkSet
    for set in $benchmarkSet; do
      benchDir=$(basename $set)
      runDir=$PWD

      mkdir -p $benchDir
      cd $benchDir

      if [ -f "$runDir/benchfiles/isSlurm" ]; then
	sbatch $runDir/$set
	echo $sbatch $runDir/$set
      else
	$runDir/$set
      fi

      cd $runDir
    done
  ;;

  "analyze")

  ;;

  *)
    showHelp
  ;;
esac

