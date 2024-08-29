#!/usr/bin/env sh
#(C)2019-2022 Pim Snel - https://github.com/mipmip/RUNME.sh
CMDS=();DESC=();NARGS=$#;ARG1=$1;make_command(){ CMDS+=($1);DESC+=("$2");};usage(){ printf "\nUsage: %s [command]\n\nCommands:\n" $0;line="              ";for((i=0;i<=$(( ${#CMDS[*]} -1));i++));do printf "  %s %s ${DESC[$i]}\n" ${CMDS[$i]} "${line:${#CMDS[$i]}}";done;echo;};runme(){ if test $NARGS -eq 1;then eval "$ARG1"||usage;else usage;fi;}

make_command "nixclean" "Run nix garbage collector"
nixclean(){
  sudo nix-collect-garbage -d
  nix-collect-garbage -d
  sudo rm -Rf /root/.cache/nix/eval-cache-v2
}

make_command "macbrew" "Run brew bundle"
macbrew(){
  cd ~ && brew bundle
}

make_command "pcirescan" "Rescan for devices that don't wake up"
pcirescan(){
  sudo echo "1" /sys/bus/pci/rescan
}

make_command "up_home" "Add latest home-manager updates"
up_home(){
  git add ./home && home-manager switch --impure --flake .\#$USER@$(hostname)
}

make_command "missing_modules" "List missing modules in configuration"
missing_modules(){
  files=(modules/*.nix)
  hosts=(hosts/*)

  for hostdir in "${hosts[@]}"
  do
    host=`basename $hostdir`
    echo Missing modules for $host

    for filename in "${files[@]}"
    do
      grep -q $filename hosts/$host/configuration.nix || echo ../../${filename}
    done

    echo

  done
}

# MACHINE BOOTSTRAP COMMAND
make_command "setup_aws_key" "copy credentials-file"
setup_aws_key(){
  if [ ~/.aws/credentials ]; then
    cp ~/.aws/credentials ~/.aws/credentials.bak
    chmod 600 ~/.aws/credentials.bak
  fi

  age --decrypt -i ~/.ssh/id_ed25519 ./secrets/aws-credentials-copy.age > ~/.aws/credentials
  chmod 600 ~/.aws/credentials
}

make_command "disable_mac_trackpad" "disable trackpad when it acts funny"
disable_mac_trackpad(){
  xinput set-prop 13 "Device Enabled" 0
}

make_command "fixmacnixpath" "set nix path on the mac"
fixmacnixpath(){
  set -a
  . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  . ~/.nix-profile/etc/profile.d/hm-session-vars.sh

  export NIX_PROFILES
  export NIX_SSL_CERT_FILE
  export MANPATH="$NIX_LINK/share/man:$MANPATH"
  export PATH=$PATH
  echo $PATH
  export  __HM_SESS_VARS_SOURCED
}


make_command "technativeawsupdate" "update account info from technative"
technativeawsupdate(){
  aws --profile=web_dns s3 cp s3://docs-mcs.technative.eu-longhorn/managed_service_accounts.json ~/.aws/
}


runme
