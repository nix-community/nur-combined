{ config, lib, pkgs, ... }:

# TODO DB_PASSWORD=$(head -n1 ${cfg.database.passwordFile})
# TODO Assert on password prescence
# TODO db password is visible during db creation
# TODO readonly read-only db user
# TODO fcgiwrap for monika
# TODO Drawgantt
# TODO copy monika

with lib;

let
  cfg = config.services.oar;
pgSuperUser = config.services.postgresql.superUser;

configFile = pkgs.writeTextDir "oar.conf"
''
  
    '';

etcOar = pkgs.symlinkJoin {
  name = "etc-oar";
  paths = [ configFile ] ++ cfg.extraConfigPaths;
};


inherit (import ./oar-conf.nix { pkgs=pkgs; cfg=cfg;} ) oarBaseConf;

oarVisualization = pkgs.stdenv.mkDerivation {
  name = "oar_visualization";
  phases          = [ "installPhase" ];
  buildInputs     = [  ];
  installPhase = ''
    mkdir -p $out/monika
    cp -r ${cfg.package}/visualization_interfaces/Monika/lib $out/monika/
    cp ${cfg.package}/visualization_interfaces/Monika/monika.css $out/monika/

    substitute ${cfg.package}/visualization_interfaces/Monika/monika.cgi.in $out/monika/monika.cgi \
      --replace "%%OARCONFDIR%%" /etc/oar

    substitute ${cfg.package}/visualization_interfaces/Monika/monika.conf.in $out/monika/monika.conf \
      --replace "%%WWWROOTDIR%%" $out/monika
  '';
};


oarTools = pkgs.stdenv.mkDerivation {
  name = "oar_tools";
  phases          = [ "installPhase" ];
  buildInputs     = [  ];
  installPhase = ''
    mkdir -p $out/bin

    #oarsh
    substitute ${cfg.package}/tools/oarsh/oarsh.in $out/bin/oarsh \
      --replace "%%OARHOMEDIR%%" ${cfg.oarHomeDir} \
      --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
      --replace /usr/bin/ssh /run/current-system/sw/bin/ssh
    chmod 755 $out/bin/oarsh    
      
    #oarsh_shell
    substitute ${cfg.package}/tools/oarsh/oarsh_shell.in $out/bin/oarsh_shell \
      --replace "/bin/bash" "${pkgs.bash}/bin/bash" \
      --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
      --replace "\$OARDIR/oardodo/oardodo" /run/wrappers/bin/oardodo \
      --replace "%%OARCONFDIR%%" /etc/oar \
      --replace "%%OARDIR%%" /run/wrappers/bin \

    chmod 755 $out/bin/oarsh_shell

    #oardodo
    substitute ${cfg.package}/tools/oardodo.c.in oardodo.c\
      --replace "%%OARDIR%%" /run/wrappers/bin \
      --replace "%%OARCONFDIR%%" /etc/oar \
      --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
      --replace "%%ROOTUSER%%" root \
      --replace "%%OAROWNER%%" oar

    $CC -Wall -O2 oardodo.c -o $out/oardodo_toWrap

    #oardo -> cli
    gen_oardo () {
      substitute ${cfg.package}/tools/oardo.c.in oardo.c\
        --replace TT/usr/local/oar/oarsub ${pkgs.nur.repos.kapack.oar}/bin/$1 \
        --replace "%%OARDIR%%" /run/wrappers/bin \
        --replace "%%OARCONFDIR%%" /etc/oar \
        --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
        --replace "%%OAROWNER%%" oar \
        --replace "%%OARDOPATH%%"  /run/wrappers/bin:/run/current-system/sw/bin
        
      $CC -Wall -O2 oardo.c -o $out/$2
    }
   
    # generate cli
    
    a=(oarsub3 oarstat3 oardel3 oarnodes3 oarnodesetting3)
    b=(oarsub oarstat oardel oarnodes oarnodesetting)
    
    for (( i=0; i<''${#a[@]}; i++ ))
    do
      echo generate ''${b[i]}
      gen_oardo ''${a[i]} ''${b[i]}
    done

  '';
};

in

{

  ###### interface
  
  meta.maintainers = [ maintainers.augu5te ];

  options = {
    services.oar = {

      package = mkOption {
        type = types.package;
        default = pkgs.nur.repos.kapack.oar;
        defaultText = "pkgs.nur.repos.kapack.oar";
      };

      privateKeyFile =  mkOption {
          type = types.str;
          default = "/run/keys/oar_id_rsa_key";
          description = "Private key for oar user";
      };

      publicKeyFile =  mkOption {
          type = types.str;
          default = "/run/keys/oar_id_rsa_key.pub";
          description = "Public key for oar user";
      };
      
      oarHomeDir = mkOption {
          type = types.str;
          default = "/var/lib/oar";
          description = "Home for oar user ";
      };

      database = {
        username = mkOption {
          type = types.str;
          default = "oar";
          description = "Username for the postgresql connection";
        };
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = ''
            Host of the postgresql server. 
          '';
        };

        passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/keys/oar-dbpassword";
        description = ''
          A file containing the password corresponding to
          <option>database.user</option>.
        '';
        };
        
        dbname = mkOption {
          type = types.str;
          default = "oar";
          description = "Name of the postgresql database";
        };
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra configuration options that will be added verbatim at
          the end of the slurm configuration file.
        '';
      };
      
      extraConfigPaths = mkOption {
        type = with types; listOf path;
        default = [];
        description = ''
          Add extra nix store
          paths that should be merged into same directory as
          <literal>oar.conf</literal>.
        '';
      };

      client = {
        enable = mkEnableOption "OAR client";
      };
      
      node = {
        enable = mkEnableOption "OAR node";
        register = mkEnableOption "Register node into OAR server";
      };
      
      server = {
        enable = mkEnableOption "OAR server";
      };
      
      dbserver = {
        enable = mkEnableOption "OAR database";
      };

      web = {
        enable = mkEnableOption "OAR web apps and rest-api";
      };
      
    };
  };
  ###### implementation
  
  config =  mkIf ( cfg.client.enable ||
                   cfg.node.enable ||
                   cfg.server.enable ||
                   cfg.dbserver.enable ) {


    environment.etc."oar-base.conf" = { mode = "0600"; source = oarBaseConf; };

    # add package*
    # TODO oarVisualization conditional
    environment.systemPackages =  [ oarVisualization oarTools pkgs.taktuk pkgs.xorg.xauth pkgs.nur.repos.kapack.oar ];
 
    # manage setuid for oardodo and oarcli 
    security.wrappers = {
      oardodo = {
        source = "${oarTools}/oardodo_toWrap";
        owner = "root";
        group = "oar";
        setuid = true;
        permissions = "u+rwx,g+rx";
      };
    } // lib.genAttrs ["oarsub" "oarstat" "oardel" "oarnodes" "oarnodesetting"]
      (name: {
      source = "${oarTools}/${name}";
      owner = "root";
      group = "oar";
      setuid = true;
      permissions = "u+rx,g+x,o+x";
    });
        
    # oar user declaration
    users.users.oar = mkIf ( cfg.client.enable || cfg.node.enable || cfg.server.enable )  {
      description = "OAR user";
      home = cfg.oarHomeDir;
      #shell = pkgs.bashInteractive;
      shell = "${oarTools}/bin/oarsh_shell";
      group = "oar";
      uid = 745;
      # openssh
    };
    users.groups.oar.gid = mkIf ( cfg.client.enable || cfg.node.enable || cfg.server.enable) 735;

    systemd.services.oar-user-init = {
      wantedBy = [ "network.target" ];      
      before = [ "network.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # TODO oar/log proper handling
        touch /tmp/oar.log
        chmod 666 /tmp/oar.log

        mkdir -p ${cfg.oarHomeDir}
        chown oar:oar ${cfg.oarHomeDir}

        echo "[ -f ${cfg.oarHomeDir}/.bash_oar ] && . ${cfg.oarHomeDir}/.bash_oar" > ${cfg.oarHomeDir}/.bashrc
        echo "[ -f ${cfg.oarHomeDir}/.bash_oar ] && . ${cfg.oarHomeDir}/.bash_oar" > ${cfg.oarHomeDir}/.bash_profile
        cat <<EOF > ${cfg.oarHomeDir}/.bash_oar
        #
        # OAR bash environnement file for the oar user
        #
        # /!\ This file is automatically created at update installation/upgrade. 
        #     Do not modify this file.
        #      
        bash_oar() {
          # Prevent to be executed twice or more
          [ -n "$OAR_BASHRC" ] && return
          export PATH="/run/wrappers/bin/:/run/current-system/sw/bin:$PATH"
          OAR_BASHRC=yes
        }
      
        bash_oar
        EOF

        cd ${cfg.oarHomeDir}  
        chown oar:oar .bashrc .bash_profile .bash_oar 

        # create and populate .ssh
        mkdir .ssh

        cat <<EOF > .ssh/config
        Host *
        ForwardX11 no
        StrictHostKeyChecking no
        PasswordAuthentication no
        AddressFamily inet
        Compression yes
        Protocol 2
        EOF
        
        cp ${cfg.privateKeyFile} .ssh/id_rsa
        cp ${cfg.publicKeyFile} .ssh/id_rsa.pub
        echo -n 'environment="OAR_KEY=1" ' > .ssh/authorized_keys
        cat ${cfg.publicKeyFile} >> .ssh/authorized_keys

        chown -R oar:oar .ssh
        chmod 700 .ssh
        chmod 600 .ssh/*
        chmod 644 .ssh/id_rsa.pub
      '';
    };

    # TODO CHANGE environment.etc...
    systemd.services.oar-conf-init = {
      wantedBy = [ "network.target" ];
      before = [ "network.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /etc/oar

        # copy some required and useful scripts
        cp ${cfg.package}/tools/*.pl ${cfg.package}/tools/*.sh /etc/oar/

        cat <<EOF > /etc/oar/oar.conf
#
# Database type ("mysql" or "Pg")
DB_TYPE="Pg"

# DataBase hostname
DB_HOSTNAME="server"

# DataBase port
DB_PORT="5432"

# Database base name
DB_BASE_NAME="oar"

# DataBase user name
DB_BASE_LOGIN="oar"
        
# DataBase user password
DB_BASE_PASSWD="oar"

# DataBase read only user name
DB_BASE_LOGIN_RO="oar_ro"

# DataBase read only user password
DB_BASE_PASSWD_RO="oar_ro"

# OAR server hostname
SERVER_HOSTNAME="server"

# OAR server port
SERVER_PORT="6666"

# when the user does not specify a -l option then oar use this
OARSUB_DEFAULT_RESOURCES="/resource_id=1"

# which real resource must be used when using the "nodes" keyword ?
OARSUB_NODES_RESOURCES="network_address"

# force use of job key even if --use-job-key or -k is not set.
OARSUB_FORCE_JOB_KEY="no"

# OAR log level: 3(debug+warnings+errors), 2(warnings+errors), 1(errors)
LOG_LEVEL="3"

# Log categories to display in the log file.
# Ex: LOG_CATEGORIES="scheduler,main,energy"
# if LOG_CATEGORIES="all" every category will be logged.
LOG_CATEGORIES="all"

# If you want to debug oarexec on nodes then affect 1 (only effective if DETACH_JOB_FROM_SERVER = 1)
OAREXEC_DEBUG_MODE="0"

# oarexec default temporary directory
# This value MUST be the same in all oar.conf on all nodes of the cluster
OAR_RUNTIME_DIRECTORY="/var/lib/oar"

# OAR log file
#LOG_FILE="/var/log/oar.log"
LOG_FILE="/tmp/oar.log"

DEBUG_REMOTE_COMMANDS="yes"

# Specify where we are connected with a job of the deploy type
DEPLOY_HOSTNAME="frontend"

# Specify where we are connected with a job of the cosystem type
COSYSTEM_HOSTNAME="frontend"

# Specify the database field to use to fill the file on the first node of the
# job in $OAR_NODE_FILE (default is 'network_address'). Only resources with
# type=default are displayed in this file.
#NODE_FILE_DB_FIELD="network_address"

# Specify the database field that will be considered to fill the node file used
# by the user on the first node of the job. for each different value of this
# field then OAR will put 1 line in the node file (default: resource_id). 
#NODE_FILE_DB_FIELD_DISTINCT_VALUES="resource_id"

# If you want to free a process per job on the server you can change this tag
# into 1 (you must enable all nodes to connect to SERVER_PORT on the
# SERVER_HOSTNAME)
DETACH_JOB_FROM_SERVER="1"

# MAX_CONCURRENT_JOBS_STARTING_OR_TERMINATING is the maximum number of jobs
# treated simultaneously (default is 25).
# This is the maximum number of bipbip processes launched at a time
#MAX_CONCURRENT_JOBS_STARTING_OR_TERMINATING=25

# Command to use to connect to other nodes (default is "ssh" in the PATH)
OPENSSH_CMD="${pkgs.openssh}/bin/ssh -p 6667"

# Set the timeout value for each ssh connection (default is 120)
#OAR_SSH_CONNECTION_TIMEOUT="200"

# When a oardel is requested on a the job then OAR will try to kill it and if
# nothing respond in JOBDEL_WALLTIME seconds then the job is EXTERMINATED and
# the resources turned into the Suspected state (default is 300s)
#JOBDEL_WALLTIME="300"

# If you have installed taktuk and want to use it to manage remote
# admnistration commands then give the full command path
# (with your options except "-m" and "-o").
# You don t also have to give any taktuk command.
# (taktuk version must be >= 3.6)
TAKTUK_CMD="/run/current-system/sw/bin/taktuk -t 30 -s"

# Change the meta scheduler in use.
#META_SCHED_CMD="oar_meta_sched"

###############################################################################

########################################################################
# Pingchecker options:                                                 #
# How to check if the nodes have a good health or not. This choice is  #
# directly linked to the Suspected state of the resources.             #
# By default OAR uses only "ping". it requests no configuration but it #
# is not accurate about the state of the nodes and it is slow          #
###############################################################################
#
# Set the frequency for checking Alive and Suspected resources (0 means never)
FINAUD_FREQUENCY="300"

# Set time after which Suspected resources become Dead (default is 0 and it
# means never) 
#DEAD_SWITCH_TIME="600"

# Set to yes if you want to check the nodes that runs jobs. (no is the default value)
#CHECK_NODES_WITH_RUNNING_JOB='no'

# Set to yes if you want to check the aliveness of nodes just after the end of
# each jobs.
#ACTIVATE_PINGCHECKER_AT_JOB_END="no"

# Uncomment only one of the following PINGCHECKER configuration

# sentinelle.pl
# If you want to use sentinelle.pl then you must use this tag.
# (sentinelle.pl is like a "for" of ssh but it adds timeout and window to 
# avoid overloading the server)
# (sentinelle.pl is provided with OAR in the install directory)
PINGCHECKER_SENTINELLE_SCRIPT_COMMAND="/usr/local/lib/oar/sentinelle.pl -t 30 -w 20"

# Taktuk
# taktuk may be used to check aliveness of nodes.
# Give the arguments of the taktuk command WITHOUT format outputs
# (DO NOT use "-o" option).
# See TAKTUK_CMD tag in this file to specify the path of the taktuk command
PINGCHECKER_TAKTUK_ARG_COMMAND="broadcast exec timeout 5 kill 9 [ true ]"
#PINGCHECKER_TAKTUK_ARG_COMMAND="broadcast exec timeout 5 kill 9 [ oarnodecheckquery ]"
#PINGCHECKER_TAKTUK_ARG_COMMAND="broadcast exec timeout 5 kill 9 [ /path/on/nodes/to/my/check/script.sh ]"

# fping
# fping may be used instead of ping to check aliveness of nodes.
# uncomment next line to use fping. Give the complete command path.
#PINGCHECKER_FPING_COMMAND="/usr/bin/fping -q"

# nmap
# nmap may be used instead of ping to check aliveness of nodes.
# uncomment next line to use nmap. Give the complete command path.
# It will test to connect on the ssh port (22)
#PINGCHECKER_NMAP_COMMAND="/usr/bin/nmap -p 22 -n -T5"

# GENERIC command
# a specific script may be used instead of ping to check aliveness of nodes.
# uncomment next line and give the complete command path and its arguments.
# The script must return bad nodes on STDERR (1 line for a bad node and it must
# have exactly the same name that OAR has given in argument of the command)
#PINGCHECKER_GENERIC_COMMAND="/path/to/command arg1 arg2"

###############################################################################

######################
# Mail configuration #
###############################################################################
#
# OAR information may be notified by email to the administror
# set accordingly to your configuration and uncomment the next lines to
# activate the feature.
# (If this tag is right configured then users can use "--notify" option of oarsub
# to receive mails about their jobs)
#MAIL_SMTP_SERVER="smtp.serveur.com"

# You can specify several recipients with a comma between each email address
#MAIL_RECIPIENT="user@domain.com"
#MAIL_SENDER="oar@domain.com"

###############################################################################

###########
# Scripts #
###############################################################################
#
# Set the timeout for the prologue and epilogue execution on computing nodes
#PROLOGUE_EPILOGUE_TIMEOUT="60"

# Files to execute before and after each job on the first computing node
# (by default nothing is executed)
#PROLOGUE_EXEC_FILE="/path/to/prog"
#EPILOGUE_EXEC_FILE="/path/to/prog"

# Set the timeout for the prologue and epilogue execution on the OAR server
#SERVER_PROLOGUE_EPILOGUE_TIMEOUT="60"

# Files to execute before and after each job on the OAR server (by default
# nothing is executed)
#SERVER_PROLOGUE_EXEC_FILE="/path/to/prog"
#SERVER_EPILOGUE_EXEC_FILE="/path/to/prog"

#
# File to execute just after a group of resources has been supected. It may 
# be used to trigger automatic actions to heal the resources. The script is 
# started with the list of resources put in its STDIN: resource_id followed
# by a space and the network_address (one line per resource)
#SUSPECTED_HEALING_EXEC_FILE="/path/to/prog"
#SUSPECTED_HEALING_TIMEOUT="10"

########################
# Scheduler parameters #
###############################################################################
#
# Maximum of seconds used by a scheduler
SCHEDULER_TIMEOUT="30"

# Number of processes to use when performing scheduling calculations
# (default is 1)
SCHEDULER_NB_PROCESSES=1

# Time to add between each jobs (for example: time for administration tasks or
# time to let computers to reboot)
# minimum time is 1 second
# default time is 60 seconds
SCHEDULER_JOB_SECURITY_TIME="60"

# Number of seconds before the start of an advance reservation, which besteffort
# jobs must be killed at (in order to let time to get nodes back and healthy 
# for the advance reservation). Default is 0 seconds.
# If SCHEDULER_BESTEFFORT_KILL_DURATION_BEFORE_RESERVATION < SCHEDULER_JOB_SECURITY_TIME
# then SCHEDULER_JOB_SECURITY_TIME is used instead.
#SCHEDULER_BESTEFFORT_KILL_DURATION_BEFORE_RESERVATION=0

# Minimum time in seconds that can be considered like a hole where a job could
# be scheduled in (if you have performance problems, you can try to increase
# this)
SCHEDULER_GANTT_HOLE_MINIMUM_TIME="300"

# You can add an order preference on resources assigned by the
# system(SQL ORDER syntax)
SCHEDULER_RESOURCE_ORDER="scheduler_priority ASC, state_num ASC, available_upto DESC, suspended_jobs ASC, network_address ASC, resource_id ASC"

# If next line is uncommented then OAR will automatically update the value of 
# "scheduler_priority" field corresponding to the besteffort jobs.
# The syntax is field names separated by "/". The value affected to 
# "scheduler_priority" depends of the position of the field name.
SCHEDULER_PRIORITY_HIERARCHY_ORDER="network_address/resource_id"

# You can specify a type of resources that will be always assigned for each job
# (for exemple: enable all jobs to be able to log on the cluster frontales)
# For more information, see the FAQ
#SCHEDULER_RESOURCES_ALWAYS_ASSIGNED_TYPE="frontal"

# This says to the scheduler to treate resources of these types, where there is
# a suspended job, like free ones. So some other jobs can be scheduled on these
# resources. (list resource types separate with spaces; Default value is
# nothing so no other job can be scheduled on suspended job resources)
#SCHEDULER_AVAILABLE_SUSPENDED_RESOURCE_TYPE="default licence VLAN"
SCHEDULER_AVAILABLE_SUSPENDED_RESOURCE_TYPE="default"

# This value is a minimun delay in seconds between to scheduler run.
# In other words: the scheduler will only be launched if its last call is at
# least 5s old.  This lets other OAR modules have more time to run.
# Warning: this delay will impact the validation of the advance reservations.
# Default value is 5s.
#SCHEDULER_MIN_TIME_BETWEEN_2_CALLS=5

# For a debug purpose, scheduler decisions can be logged into the database
# Uncomment the next line in order to activate the logging mechanism
#SCHEDULER_LOG_DECISIONS="yes"

# Time to wait when a reservation has not got all resources that it has reserved
# (some resources may have become Suspected or Absent since the job submission)
# before to launch the job on the remaining resources (default is 300s)
#RESERVATION_WAITING_RESOURCES_TIMEOUT="300"

# Set the granularity of the OAR accounting feature (in seconds)
# Used by the oaraccounting command and the 
# oar_sched_gantt_with_timesharing_and_fairsharing* to calculate the timesharing
# policy. Default is 1 day (86400s)
#ACCOUNTING_WINDOW="86400"

################################
# KAMELOT Scheduler parameters #
###############################################################################
# Be carefull hierarchy labels must be declare below to be use in resource 
# request. Labels' order does not matter here. Default value is
# "resource_id,network_address,cpu,core" 
#HIERARCHY_LABELS="resource_id,network_address,cpu,core" 

# Number of jobs which will be scheduled by scheduling round for each queue where Kamelot is used 
# ***NOT LIMITED by default***
#MAX_JOB_PER_SCHEDULING_ROUND=1000

# Mode to get resources and generate hierarchy levels, values are following:
# default:     all is done dynamically, does not scale very beyond 5000 resourcess
#
# mono:        use only one hierarchy level resource_id or core (the FIRST label in HIERARCHY_LABELS)
#              suitable to large platform and particular performance evaluation (only for expert users)
#
# precomputed: NOT YET IMPLEMENTED (upto now default mode will be used)
#
#KAMELOT_GET_RESOURCES_HIERARCHY_MODE="default"

##############################################

###############################################################
# Parameters available if you are using the                   #
# oar_sched_gantt_with_timesharing_and_fairsharing* scheduler #
###############################################################################
#
# Specify the number of job to take care at each time
# Default is 30
SCHEDULER_FAIRSHARING_MAX_JOB_PER_USER=30

# Number of seconds to consider for the fairsharing
# Default is 30 days
#SCHEDULER_FAIRSHARING_WINDOW_SIZE=2592000

# Specify the target percentages for project names (0 if not specified)
# /!\ the syntax is a perl hash table definition with project names as keys
# AND EVERYTHING MUST BE ON THE SAME LINE
#SCHEDULER_FAIRSHARING_PROJECT_TARGETS="{ first => 75, default => 25 }"

# Specify the target percentages for users (0 if not specified)
# /!\ the syntax is a perl hash table definition with project names as keys
# AND EVERYTHING MUST BE ON THE SAME LINE
#SCHEDULER_FAIRSHARING_USER_TARGETS="{ toto => 75, titi => 10, tutu => 15 }"

# Weight given to each criteria
# By default the job project name is not taken in account
#SCHEDULER_FAIRSHARING_COEF_PROJECT=0

# By default, effective job duration counts twice than the asked one ("asked" =
# walltime given by the user )
#SCHEDULER_FAIRSHARING_COEF_USER=2
#SCHEDULER_FAIRSHARING_COEF_USER_ASK=1

##############################################

###############################################################
# TOKEN feature                                               #
# Parameters available if you are using the                   #
# oar_sched_gantt_with_timesharing_and_fairsharing scheduler* #
###############################################################################
#
# With this token feature you are able to filter which jobs can be scheduled
# depending on outside resources (like licence server for some proprietary
# softwares)
# So the users can do:
#   oarsub -l nodes=2 -t token:fluent=12 ./script.sh
# This job will be launched only if the script corresponding to the "fluent"
# token returns a value greater or equal than 12.
# You can use several "-t token:..." arguments (all token constraints must be
# ok)

# Specify the scripts to use for each token
# The scripts MUST print only 1 line with a number
#SCHEDULER_TOKEN_SCRIPTS="{ fluent => '/usr/local/bin/check_fluent.sh arg1 arg2', soft2 => '/usr/local/bin/check_soft2.sh arg1' }"

###############################################################################

###########################################################################
# WALLTIME CHANGE                                                         #
# Allow a user to request a change to the walltime of a job. Change can   #
# be an increase or a decrease. Increase is basically only granted if it  #
# does not conflict with the next jobs.                                   #
###############################################################################
#
# Activation of the feature, set to "yes" to activate (global setting, cannot be used per queue)
# Default is "no", disabled
#WALLTIME_CHANGE_ENABLED="no"

# Walltime change maximum allowed increase
# -1 means that the walltime increase is not limited
#  0 means that the walltime increase is allowed for oar and root only (with no limit)
# >0 sets the maximum increase of walltime users can request, in seconds
# If the value is in the ]0,1[ range, the actual value will be computed as that ratio of the walltime of the job
# Default is 0
#WALLTIME_MAX_INCREASE=0

# Set the minimum walltime of jobs for which change can be requested
# Default is 0, i.e. no minimum walltime
#WALLTIME_MIN_FOR_CHANGE=0

# Set walltime change apply time: postpone the trial/application of the requested change to the given value in second before the predicted end of the job
# If the value is in the ]0,1[ range, the actual value will be computed as that ratio of the walltime of the job
# Default is 0, i.e. not postponed
# NB: negative changes are applied at once
#WALLTIME_CHANGE_APPLY_TIME=0

# Set an increment so that walltime change if added gradually
# If the value is in the ]0,1[ range, the actual value will be computed as that ratio of the walltime of the job
# Default is 0, i.e. extratime is not gradual
# NB: negative changes are applied at once
#WALLTIME_INCREMENT=0

# List users (* for all) for which walltime change can be forced to apply at once (force no wait / no increment)
# Default is "", i.e. only root and the oar user are allowed
#WALLTIME_ALLOWED_USERS_TO_FORCE=""

# List users (* for all) for which walltime change can delay the next batch jobs (i.e. only advance reserations cannot be moved)
# Default is "", i.e. only root and the oar user are allowed
#WALLTIME_ALLOWED_USERS_TO_DELAY_JOBS=""

# The last 6 settings can also be provided per queue, using the Perl hash syntax with the queue names as the keys.
# Not defined queues get the value associated to the _ key, or if not defined either, the default value of the setting (see above)
# e.g.:
# - Allow walltime increase requests for up to 2 hours for the default queue only (0 for others):
#WALLTIME_MAX_INCREASE="{default => 7200}"
# - Allow any user to force the walltime change of a job in all but the besteffort queue:
#WALLTIME_ALLOWED_USERS_TO_FORCE="{_ => '*', besteffort => '''}"

###########################################################################
# ENERGY SAVING                                                           #
# (Management of automatic wake-up and shut-down of the nodes when they   #
# are not used)                                                           #
# You have to set up the "available_upto" property of your resources:     #
#  available_upto=0           : to disable the wake-up and shutdown       #
#  available_upto=1           : to disable the wake-up (but not the halt) #
#  available_upto=2147483647  : to disable the halt (but not the wake-up) #
#  available_upto=2147483646  : to enable wake-up/halt forever            #
#  available_upto=<timestamp> : to enable the halt, and the wake-up until #
#                               the date given by <timestamp>             #
# The energy saving mechanism should be coupled with the mechanism to     #
# automatically set the nodes in the Alive state at boot time. Information#
# for that mechanism is provided on the following page:                   #
# https://oar.imag.fr/wiki:customization_tips#start_stop_of_nodes_using_ssh_keys
###############################################################################
#
# Parameter for the scheduler to decide when a node is idle.
# Number of seconds since the last job was terminated on nodes
#SCHEDULER_NODE_MANAGER_IDLE_TIME="600"

# Parameter for the scheduler to decide if a node will have enough time to sleep.
# Number of seconds before the next job
#SCHEDULER_NODE_MANAGER_SLEEP_TIME="600"

# Parameter for the scheduler to know when a node has to be woken up before the
# beginning of the job when a reservation is scheduled on a resource on this node
# Number of seconds for a node to wake up
#SCHEDULER_NODE_MANAGER_WAKEUP_TIME="600"

# When OAR scheduler wants some nodes to wake up then it launches this command
# and puts on its STDIN the list of nodes to wake up (one hostname by line).
# !! This variable is ignored if you set ENERGY_SAVING_INTERNAL to yes. !!
# The scheduler looks at the available_upto field in the resources table to know
# if the node will be started for enough time.
# There's no nodes management with this method: if you want nodes to be suspected
# when they do not wake up in time, then you have to use ENERGY_SAVING_INTERNAL=yes
# and set up ENERGY_SAVING_NODE_MANAGER_WAKE_UP_CMD.
#SCHEDULER_NODE_MANAGER_WAKE_UP_CMD="/etc/oar/wake_up_nodes.sh"

# When OAR considers that some nodes can be shut down, it launches this command
# and puts the node list on its STDIN (one hostname by line).
# !! This variable is ignored if you set ENERGY_SAVING_INTERNAL to yes. !!
# There's no nodes management with this method: if you want some nodes to be kept
# alive to be reactive to small jobs, then you have to use ENERGY_SAVING_INTERNAL=yes
# and set up ENERGY_SAVING_NODE_MANAGER_SLEEP_CMD.
#SCHEDULER_NODE_MANAGER_SLEEP_CMD="/path/to/the/command args"
#SCHEDULER_NODE_MANAGER_SLEEP_CMD="taktuk -s -f - -t 3 b e t 3 k 9 [ oardodo halt ]"
#SCHEDULER_NODE_MANAGER_SLEEP_CMD="/usr/local/lib/oar/sentinelle.pl -f - -t 3 -p 'oardodo halt'"

# Choose wether to use the internal energy saving module or not. If set to yes,
# please, also provide convenient configuration for all the ENERGY_* variables.
# If set to no, then you have to set up SCHEDULER_NODE_MANAGER_WAKE_UP_CMD
# and SCHEDULER_NODE_MANAGER_SLEEP_CMD
# Benefits of this module are:
# - nodes are suspected if they do not wake up before a timeout
# - some nodes can be kept always alive depending on some properties
# - the launching of wakeup/shutdown commands can be windowized to prevent
#   from electric peeks 
# Possible values are "yes" and "no"
ENERGY_SAVING_INTERNAL="no"

# Path to the script used by the energy saving module to wake up nodes. 
# This command is executed from the oar server host.
# OAR puts the node list on its STDIN (one hostname by line).
# The scheduler looks at the available_upto field in the resources table to know
# if the node will be started for enough time.
#ENERGY_SAVING_NODE_MANAGER_WAKE_UP_CMD="/etc/oar/wake_up_nodes.sh"

# Path to the script used by the energy saving module to shut down nodes.
# This command is executed from the oar server host.
# OAR puts the node list on its STDIN (one hostname by line).
#ENERGY_SAVING_NODE_MANAGER_SLEEP_CMD="/etc/oar/shut_down_nodes.sh"

# Timeout to consider a node broken (suspected) if it has not woken up
# The value can be an integer of seconds or a set of pairs.
# For example, "1:500 11:1000 21:2000" will produce a timeout of 500
# seconds if 1 to 10 nodes have to wakeup, 1000 seconds if 11 t 20 nodes
# have to wake up and 2000 seconds otherwise.
#ENERGY_SAVING_NODE_MANAGER_WAKEUP_TIMEOUT="900"

# You can set up a number of nodes that must always be on. You can use the 
# syntax in the examples if you want a number of alive nodes of different types
# (corresponding to a specific sql properties requierement).
# Example 1: keep alive 10 nodes on the whole cluster:
#ENERGY_SAVING_NODES_KEEPALIVE="type='default':10"
# Example 2: keep alive 4 nodes on the paradent cluster AND 6 nodes on the 
# paraquad cluster AND 2 nodes accepting besteffort
#ENERGY_SAVING_NODES_KEEPALIVE="cluster='paradent':4 & cluster='paraquad':6 & besteffort='YES':2"
# By default, keepalive is disabled:
#ENERGY_SAVING_NODES_KEEPALIVE="type='default':0"

# Parameter for the window launching mechanism embedded in OAR energy saving module
# to know the number of commands that can be executed in parallel.
# This mechanism is used in order to sleep and wake up nodes gradually.
# Window size minimum is 1
#ENERGY_SAVING_WINDOW_SIZE="25"

# Parameter to bypas the window mechanism embedded in the energy saving module.
# Possible values are "yes" and "no"
# When set to "yes", the list of nodes to wake up or shut down is passed to 
# ENERGY_SAVING_NODE_MANAGER_*_CMD through stdin. 
#ENERGY_SAVING_WINDOW_FORKER_BYPASS="no"

# Time in second between execution of each window.
# Minimum is 0 to set no delay between each window.
# This value must be smaller than ENERGY_SAVING_NODE_MANAGER_TIMEOUT.
#ENERGY_SAVING_WINDOW_TIME="60"

# Timeout to set the maximum duration for a execution window
# This value must be greater than ENERGY_SAVING_WINDOW_TIME.
#ENERGY_SAVING_WINDOW_TIMEOUT="120"

# The energy saving module can be automatically restarted after reaching
# this number of cycles. This is a workaround for some DBD modules that do 
# not always free memory correctly.
#ENERGY_MAX_CYCLES_UNTIL_REFRESH=5000

################################################################################

##############################
# Suspend/Resume job feature #
###############################################################################
#
# Name of the perl script that manages suspend/resume.
# (default is /etc/oar/suspend_resume_manager.pl)
#SUSPEND_RESUME_FILE="/etc/oar/suspend_resume_manager.pl"

# Files to execute just after a job was suspended and just before a job was resumed
#JUST_AFTER_SUSPEND_EXEC_FILE="/path/to/prog"
#JUST_BEFORE_RESUME_EXEC_FILE="/path/to/prog"

# Timeout for the two previous scripts
#SUSPEND_RESUME_SCRIPT_TIMEOUT="60"


# To allow users to hold or resume their jobs. By default it's restricted to oar and
# root users due to global scheduling impact and possible priority bypassing.  
#USERS_ALLOWED_HOLD_RESUME="yes"

###############################################################################

################################
# JOB_RESOURCE_MANAGER feature #
###############################################################################
# Specify the name of the database field that will be passed to the
# JOB_RESOURCE_MANAGER script.
# If this option is set then users must use oarsh instead of ssh to walk on
# the nodes they reserve using oarsub.
# Look at the CPUSET file
# (if defined, this option turn on the execution of JOB_RESOURCE_MANAGER script
# execution on each job nodes: initialize cpuset, job keys, clean nodes, ...)
JOB_RESOURCE_MANAGER_PROPERTY_DB_FIELD="cpuset"

# Name of the perl script that manages cpuset.
# (default is /etc/oar/job_resource_manager.pl which handles the linux kernel
# cpuset, job keys, clean processes, ...)
JOB_RESOURCE_MANAGER_FILE="/srv/job_resource_manager_cgroups_nixos.pl"

# Path of the relative directory where the cpusets will be created on each
# nodes(same value than in /proc/self/cpuset).
# WARNING: Change this value only if you know what you are doing.
# (Note: comment this line to disable cpuset feature on computing nodes. Thus
# if you only want to initialize job user without the cpuset, you have
# to set OARSUB_FORCE_JOB_KEY="yes")
CPUSET_PATH="/oar"

# Command to get a process cpuset
# If unset, OAR (oarsh) will read /proc/self/cpuset.
GET_CURRENT_CPUSET_CMD="cat /proc/self/cpuset | sed -e 's@^/oardocker/node[[:digit:]]\+@@'"
#GET_CURRENT_CPUSET_CMD="cat /proc/self/cpuset"

# Name of the perl script the retrieve monitoring data from compute nodes.
# This is used in oarmonitor command.
#OARMONITOR_SENSOR_FILE="/etc/oar/oarmonitor_sensor.pl"

###############################################################################

#########
# OARSH #
###############################################################################
#
# The following variable must be set to enable the use of oarsh on frontend
# machines. On other machines (compute nodes), it does not need to be set.
OARSH_OARSTAT_CMD="/usr/local/bin/oarstat"

# The following variable gives the OpenSSH options which the oarsh command must
# understand in order to parse user commands.
# The value of OPENSSH_OPTSTR must match the option string of OpenSSH ssh
# command installed on the system (mind checking it is up-to-date, as OpenSSH 
# development is very active), which can be found in the ssh.c file of the 
# OpenSSH sources. For instance, the following command extracts the option
# string of OpenSSH 7.2p2 :
#
# $ cd path/to/openssh/sources/ 
# $ grep getopt -A1 ssh.c | sed 's/.*"\(.\+\)".*/\1/' | xargs | sed 's/ //g'
# 1246ab:c:e:fgi:kl:m:no:p:qstvxACD:E:F:GI:KL:MNO:PQ:R:S:TVw:W:XYy
#
OPENSSH_OPTSTR="1246ab:c:e:fgi:kl:m:no:p:qstvxACD:E:F:GI:KL:MNO:PQ:R:S:TVw:W:XYy"

# The following variable sets the OpenSSH options which oarsh actually uses.
# Any option which is filtered out from the OPENSSH_OPTSTR variable above is 
# just ignored (see oarsh -v for debug)
# WARNING: if not fitlered out, some options may allow root exploit using oarsh.
# At least the following OpenSSH options are recommanded to be fitlered out: 
#  -a -A -i -l -o -p -E -F -G -I -w
OPENSSH_OPTSTR_FILTERED="1246b:c:e:fgkm:nqstvxCD:KL:MNO:PQ:R:S:TVW:XYy"

# The following variable forces OpenSSH configuration options for the ssh call 
# made by in oarsh, so that, for security reasons, they cannot be set by the
# user (whenever "o:" is not filtered out in the OPENSSH_OPTSTR_FILTERED
# variable above).
# WARNING: for security, do not change unless you know what you are doing
OARSH_OPENSSH_DEFAULT_OPTIONS="-oProxyCommand=none -oPermitLocalCommand=no -oUserKnownHostsFile=/var/lib/oar/.ssh/known_hosts"

# If the following variable is set to a value which is not 0, oarsh will act
# like a normal ssh, **without** the CPUSET isolation mechanism.
# WARNING: this disable a critical functionality
# This can however be useful and different from simply using ssh, as it
# provides users with a mechanism which allows to connect to compute nodes
# without having to care of their ssh configuration (e.g. key setup)
#OARSH_BYPASS_WHOLE_SECURITY="0"

###############################################################################

# Default oarstat output format.
# See oarstat "--format" option to know the available values
# (default is 1)
OARSTAT_DEFAULT_OUTPUT_FORMAT=2

###########
# OAR API #
###############################################################################

# Disable this if you are not ok with a simple pidentd "authentication"
# It is safe enough if you fully trust the client hosts (with an apropriate
# ip-based access control into apache for example)
API_TRUST_IDENT="1"

# Custom header for the html browsable format of the API
#API_HTML_HEADER="/etc/oar/api_html_header.pl"

# Custom form for posting jobs with html to the API
#API_HTML_FORM="/etc/oar/api_html_postform.pl"

# Default data structure variant
# Value can be "oar" or "simple" (the default is "simple")
# This can be override with the "?structure=<value>" part of the queries
# The "oar" variant tries to be as near as possible to the data structures
# used by the export options of the oarstat/oarnodes commands.
# The "simple" variant aims to be more simple, using arrays instead of hashes
# when it is possible.
# The first is more human readable; the second is simpler for programming.
#API_DEFAULT_DATA_STRUCTURE="simple"

# Maximum default number of items
#API_DEFAULT_MAX_ITEMS_NUMBER=500

# Default parameters for the /jobs uri
# if a "&limit=" is given, the API_DEFAULT_MAX_ITEMS_NUMBER is ignored for this uri
#API_JOBS_URI_DEFAULT_PARAMS="state=Finishing,Running,Resuming,Suspended,Launching,toLaunch,Waiting,toAckReservation,Hold"

# Set to 0 if you want the API to provide relative uris.
# Relative uris may help if your API is behind a reverse proxy, 
# as you don't have to rewrite the uris, but due to the possible confusion 
# between "resources" and "resources/", it may not work with some libraries 
# like "ruby Restfully".
# In addition, you can use the X_API_PATH_PREFIX http header variable to prepend each uris
# returned by the API by a given prefix. (for example: curl -i -H'X_API_PATH_PREFIX: http://prefix_a/la/noix/' ...)
#API_ABSOLUTE_URIS=1

# Api stress_factor script
# This script should return at least a real value between 0 and 1 that is given by 
# the OAR api for the "GET /stress_factor" URI.
# Warning: this script is run by root and the output is parsed as a list of
# variables as is!
# - A stress_factor of 0 means that everything is fine
# - A stress_factor of 1 (or more) means that the resources manager is under
# stress. That generally means that it doesn't want to manage anymore jobs!
# - Any value between 0 and 1 is allowed to define the level of stress.
# It allows the administrator to define custom criterias to tell other systems
# (those using the API) that they maybe should reduce or stop to query this
# OAR system for a while. So, this script is meant to be polled regularly.
# The script should return at least the variable "GLOBAL_STRESS=" but it
# may also provide other custom defined values.
#API_STRESS_FACTOR_SCRIPT="/etc/oar/stress_factor.sh"

# Command to generate a yaml list of resources to be created from
# a resources definition syntax submitted to the OAR API
# (POST /resources/generate)
# If the variable is not defined, this feature is disabled
#API_RESOURCES_LIST_GENERATION_CMD="/usr/sbin/oar_resources_add -Y"

# Colmet extractor script path
#API_COLMET_EXTRACT_PATH="/usr/lib/oar/colmet_extract.py"
#
# Colmet hdf5 files path with filename prefix
# The API will automatically append .<timestamp>.hdf5
#API_COLMET_HDF5_PATH_PREFIX="/var/lib/colmet/hdf5/cluster"

EOF
      '';
    };

    
    ##############
    # Node Section
    services.openssh = mkIf cfg.node.enable { enable = true; };
    
    systemd.services.oar-node =  mkIf (cfg.node.enable) {
      description = "OAR's SSH Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      stopIfChanged = false;
      path = [ pkgs.openssh ];
      preStart = ''
        # Make sure we don't write to stdout, since in case of
        # socket activation, it goes to the remote side (#19589).
        exec >&2
        if ! [ -f "/etc/oar/oar_ssh_host_rsa_key" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -N "" -f /etc/oar/oar_ssh_host_rsa_key
        fi
      '';
      serviceConfig = {
        #ExecStart = " ${pkgs.openssh}/bin/sshd -f /srv/sshd.conf";
        ExecStart = " ${pkgs.openssh}/bin/sshd -f /srv/sshd_config";
        KillMode = "process";
        Restart = "always";
        Type = "simple";
      };
    };


    systemd.services.oar-node-register =  mkIf (cfg.node.register) {
      wantedBy = [ "multi-user.target" ];      
      after = [ "network.target" "oar-user-init" "oar-node" ];
      serviceConfig.Type = "oneshot";
      path = [ pkgs.hostname ];
      script = ''/run/wrappers/bin/oarnodesetting -a -s Alive'';
    };
    
    ################
    # Server Section
    systemd.services.oar-server =  mkIf (cfg.server.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      description = "OAR server's main processes";
      restartIfChanged = false;
      environment.OARDIR = "${cfg.package}/bin";
      serviceConfig = {
        User = "oar";
        Group = "oar";
        ExecStart = "${cfg.package}/bin/oar3-almighty";
        KillMode = "process";
        Restart = "on-failure";
      };
    };  
    
    ##################
    # Database section 
    
    services.postgresql = mkIf cfg.dbserver.enable {
      #TODO TOCOMPLETE (UNSAFE)
      enable = true;
      enableTCPIP = true;
      authentication = mkForce
      ''
        # Generated file; do not edit!
        local all all              ident
        host  all all 0.0.0.0/0 md5
        host  all all ::0.0.0.0/96  md5
      '';
    };

    #networking.firewall.allowedTCPPorts = mkIf cfg.dbserver.enable [5432];
        
    systemd.services.oardb-init = mkIf cfg.dbserver.enable {
      #pgSuperUser = config.services.postgresql.superUser;
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      description = "OARD DB initialization";
      path = [ config.services.postgresql.package ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      
      # TODO DB_PASSWORD=$(head -n1 ${cfg.database.passwordFile})
      script = ''
        DB_PASSWORD=oar 
        mkdir -p /var/lib/oar
        if [ ! -f /var/lib/oar/db-created ]; then
          ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create role ${cfg.database.username} with login password '$DB_PASSWORD'";
          ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create database ${cfg.database.dbname} with owner ${cfg.database.username}";
              
          PGPASSWORD=$DB_PASSWORD ${pkgs.postgresql}/bin/psql -U ${cfg.database.username} \
            -f ${cfg.package}/setup/database/pg_structure.sql \
            -f ${cfg.package}/setup/database/default_data.sql \
            -h localhost ${cfg.database.dbname}
          touch /var/lib/oar/db-created
        fi
        '';
    };

    #################
    # Web Section

    services.nginx = mkIf cfg.web.enable {
      enable = true;
      user = "oar";
      group = "oar";
      virtualHosts.default = {
        #TODO root = "${pkgs.nix.doc}/share/doc/nix/manual";
        extraConfig = ''
          location @oarapi {
            rewrite ^/oarapi-priv/?(.*)$ /$1 break;
            rewrite ^/oarapi/?(.*)$ /$1 break;
          
            include ${pkgs.nginx}/conf/uwsgi_params;
          
            uwsgi_pass unix:/run/uwsgi/oarapi.sock;
            uwsgi_param HTTP_X_REMOTE_IDENT $remote_user;
          }
          
          location ~ ^/oarapi-priv {
            auth_basic "OAR API Authentication";
            auth_basic_user_file /etc/oarapi-users;
            error_page 404 = @oarapi;
          }

          location ~ ^/oarapi {
            error_page 404 = @oarapi;
          }

          location /monika {
            rewrite ^/monika/?$ / break;
            rewrite ^/monika/(.*)$ $1 break;
            include ${pkgs.nginx}/conf/fastcgi_params;
            try_files $fastcgi_script_name =404;
            fastcgi_pass unix:/run/oar-fcgi.sock;
            fastcgi_param SCRIPT_FILENAME ${oarVisualization}/monika.cgi;
            fastcgi_param PATH_INFO $fastcgi_script_name;
          }

        '';
      };
    };
    
    services.uwsgi = mkIf cfg.web.enable {
      enable = true;
      plugins = [ "python3" ];
      user = "oar";
      group = "oar";
      
      instance = {
        type = "emperor";
        vassals.hello = {
          socket = "/run/uwsgi/oarapi.sock";
          type = "normal";
          master = true;
          workers = 2;
          module = "oarapi:application";
          chdir = pkgs.writeTextDir "oarapi.py" ''
          from oar.rest_api.app import wsgi_app as application 
          '';
          # chdir = pkgs.writeTextDir "wsgi.py" ''
          #   from flask import Flask, request
          #   application = Flask(__name__)
            
          #   @application.route("/")
          #   def hello():
          #     return str(request.environ)
          # '';
          pythonPackages = self: with self; [ pkgs.nur.repos.kapack.oar ];
        };
      };
    };
    
  };
}


















