{pkgs, lib, cfg}:
with lib;
let

  baseConfString = ''
# Database type 
DB_TYPE="Pg"

# DataBase hostname
DB_HOSTNAME="${cfg.database.host}"

# DataBase port
DB_PORT="5432"

# Database base name
DB_BASE_NAME="${cfg.database.dbname}"

# OAR server hostname
SERVER_HOSTNAME="${cfg.server.host}"

# OAR server port
SERVER_PORT="6666"

# when the user does not specify a -l option then oar use this
OARSUB_DEFAULT_RESOURCES="/resource_id=1"

# which real resource must be used when using the "nodes" keyword ?
OARSUB_NODES_RESOURCES="network_address"

# force use of job key even if --use-job-key or -k is not set.
OARSUB_FORCE_JOB_KEY="no"

# OAR log level: 3(debug+warnings+errors), 2(warnings+errors), 1(errors)
LOG_LEVEL="1"

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
JOB_RESOURCE_MANAGER_FILE="/etc/oar/job_resource_manager_cgroups_nixos.pl"

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

OARDODO="/run/wrappers/bin/oardodo"

# (REVERSE) PROXY 
PROXY="traefik"
OAR_PROXY_BASE_URL="/proxy"
PROXY_TRAEFIK_RULES_FILE="/etc/oar/proxy/rules_oar_traefik.toml"
PROXY_TRAEFIK_ENTRYPOINT="http://localhost:5000"
  '';

vars =  mapAttrsToList (name: value: name) cfg.extraConfig;
commentedVars = map (value: "#" + value) vars;

oarBaseConfString = replaceStrings vars commentedVars baseConfString;

settingsString = concatStrings (lib.mapAttrsToList (n: v: ''${n}="${toString v}"'' + "\n") cfg.extraConfig);

in
{
  oarBaseConf = pkgs.writeText "oar-base.conf"  (oarBaseConfString + settingsString);
  oarSshdConf = pkgs.writeText "sshd_config" ''
Protocol 2

UsePAM yes

AddressFamily any
Port 6667

X11Forwarding no

PermitRootLogin prohibit-password
GatewayPorts no

ChallengeResponseAuthentication yes

PrintMotd no # handled by pam_motd

HostKey /etc/oar/oar_ssh_host_rsa_key

KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

LogLevel VERBOSE

UseDNS no

AcceptEnv OAR_CPUSET OAR_JOB_USER
PermitUserEnvironment yes

AllowUsers oar
XAuthLocation /usr/bin/xauth
'';
  monikaBaseConf = pkgs.writeText "monika-base.conf" ''
## Created on November 2007 by Joseph.Emeras@imag.fr

#################
## monika.conf ##
#################

##############################################################################
## WARNING: About the location of this file:
## monika.cgi is looking first for its configuration file in its own
## directory then in /etc/oar/
##############################################################################

##############################################################################
## CSS path for the HTML diplay
## - default is "/monika.css"
##############################################################################
#css_path = /var/www/monika.css

##############################################################################
## clustername: set the name of the cluster
## - default is "Cluster"
## - ex: clustername = "MyCluster"
##############################################################################
clustername = OAR Cluster

##############################################################################
## DataBase : set the connection parameters to the OAR PostgreSQL DataBase
##############################################################################
hostname = ${cfg.database.host}
dbport = 5432
dbname = ${cfg.database.dbname}
#username = oar_ro
#password = oar_ro


##############################################################################
## nodes_synonym: which real resource must be used when using the "nodes" 
## keyword ?
## - ex: nodes_synonym = resource_id
##       nodes_synonym = host
## - default is resource_id
##############################################################################
nodes_synonym = network_address


##############################################################################
## Summary Display: specify how to display the summary status. For each type 
## of resource, a resource hierarchy can be specified. Syntax is:
## <resource type>[:<resource>[,<resource>]...][;<resource type...>...]
## -ex: summary_display = default:nodes_synonym;licence:resource_id;
##                        memory:resource_id;userid:resource_id
## -ex: summary_display = default:host,cpu,core;licence;memory;userid
## -ex: summary_display = default:network_address
## -ex: summary_display = default:nodes_synonym
##############################################################################
summary_display = default:nodes_synonym,resource_id

##############################################################################
## nodes_per_line: set the number of node to be displayed per line in the
## reservation table
## - default is 10
## - ex: nodes_per_line = 5
##############################################################################
nodes_per_line = 2

##############################################################################
## max_cores_per_line: set the number of cores to be displayed per line in the
## reservation table
## - default is 16
## - ex: max_cores_per_line = 32
##############################################################################
max_cores_per_line = 16

##############################################################################
## nodename_regex: set the regular expression to extract nodes' short
## names (ex: node22 => 22). Use Perl regular expression syntax.
## - default is "(\d+)" ie extract the first number from the left in nodenames
## - ex: nodename_regex = cluster5node(\d+) ie basename contains a number...
## - ex: nodename_regex = ([^.]+) ie to extract the short hostname.
## - ex: nodename_regex = (.+) ie to keep the whole word if really needed.
## Rq: this regex is used to sort nodes
##############################################################################
nodename_regex = (.+)

##############################################################################
## nodename_regex_display: set the regex display on the page node names
## it is just for final display
## Rq: monika looks better with numerical only short nodenames...
##############################################################################
nodename_regex_display = (.*)

##############################################################################
## server_do_mail: set the capability of the server to handle mail. If
## true, then monika use the job owner attribut as a valid email address
## unless -M <email> is specified in qsub and then used instead
## - default is "False"
## - ex: server_do_mail = "True"
##############################################################################
#server_do_mail = "False"

##############################################################################
## user_infos : if server_do_mail is not set then you can specify a cgi page
## wich can display informations about a user. It is a link on the user name.
## The link pints on the content of user_infos+user_name
##############################################################################
#user_infos = "userInfos.cgi?"

##############################################################################
## node_group: define a group of nodes
## - ex: node_group group1 = 5-10 25 32 40-50
## - ex: node_group group2 = master nodeone nodetwo
## * Rq: monika looks better with numerical only node names.
## * Rq: nodes you define this way may be either extra nodes (ex: login nodes)
##       or the nodes in order to give them a "rescue" state (ex: Missing)
##############################################################################
#node_group login = 1-4
#node_group batch = 5-225

##############################################################################
## default_state: define the default state for a node group defined above
## - ex: default_state group1 = "StateGroup1"
##############################################################################
#default_state login = Login
#default_state batch = Missing

##############################################################################
## set_color: associate a HTML color to a node state
## - ex: set_color Down = "red"
## - ex: set_color Free = "#33ff33"
##############################################################################
set_color Down = "red"
set_color Free = "#ffffff"
set_color Absent = "#c22200"
set_color StandBy = "cyan"
set_color Suspected = "#ff7b7b"
#set_color Missing = "grey"
#set_color Login = "cyan"

##############################################################################
## color_pool: add an HTML color to dynamically use in HTML table generation
## - ex: color_pool = "#9999ff"
##       color_pool = "#ff6600"
##       color_pool = "#00cccc"
##############################################################################
color_pool = "#9999ff"
color_pool = "#00cccc"
color_pool = "pink"
color_pool = "yellow"
color_pool = "orange"
color_pool = "#ff22ff"
color_pool = "#33cc00"
color_pool = "#cc66cc"
color_pool = "#99ff99"
color_pool = "#995522"
color_pool = "orange"
color_pool = "#999999"

##############################################################################
## hidden_property: define properties not to be shown in the main page
## - ex: hidden_property = hostname
##       hidden_property = besteffort
##       hidden_property = expiryDate
##############################################################################
#hidden_property = network_address
#hidden_property = besteffort
#hidden_property = expiry_date
#hidden_property = desktop_computing
#hidden_property = cpu
#hidden_property = cpuset
#hidden_property = available_upto
#hidden_property = core
#hidden_property = finaud_decision
#hidden_property = last_job_date
#hidden_property = resource_id
#hidden_property = state
#hidden_property = state_num
#hidden_property = type
#hidden_property = mem
#hidden_property = suspended_jobs
#hidden_property = next_state
#hidden_property = next_finaud_decision
#hidden_property = deploy
#hidden_property = host


hidden_property = network_address
hidden_property = host
hidden_property = cpu
hidden_property = core
hidden_property = thread
hidden_property = cpuset
hidden_property = ip
hidden_property = hostname
#hidden_property = besteffort
hidden_property = expiry_date
hidden_property = desktop_computing
hidden_property = available_upto
hidden_property = last_available_upto
hidden_property = finaud_decision
hidden_property = last_job_date
hidden_property = resource_id
#hidden_property = state
hidden_property = state_num
#hidden_property = type
#hidden_property = mem
hidden_property = suspended_jobs
hidden_property = next_state
hidden_property = next_finaud_decision
hidden_property = deploy
hidden_property = scheduler_priority
#hidden_property = switch
'';
  drawganttBaseConf = pkgs.writeText "drawgantt-base.conf" ''
<?php
/**
 * OAR Drawgantt-SVG
 * @author Pierre Neyron <pierre.neyron@imag.fr>
 *
 */

// OAR Drawgantt SVG configuration file

////////////////////////////////////////////////////////////////////////////////
// Configuration
////////////////////////////////////////////////////////////////////////////////

// Default settings for the default view 
$CONF['default_start'] = ""; // default start and stop times (ctime values) ; unless you want to always show a
$CONF['default_stop'] = "";  // same time frame, keep those values to "" 
$CONF['default_relative_start'] = ""; // default relative start and stop times ([+-]<seconds>), mind setting it
$CONF['default_relative_stop'] = "";  // accordingly to the nav_forecast values below, eg -24*3600*0.1 and 24*3600*0.9
$CONF['default_timespan'] = 6*3600; // default timespan, should be one of the nav_timespans below
$CONF['default_resource_base'] = 'cpuset'; // default base resource, should be one of the nav_resource_bases below
$CONF['default_scale'] = 10; // default vertical scale of the grid, should be one of the nav_scales bellow

// Navigation bar configuration
$CONF['nav_timespans'] = array( // proposed timespan in the "set" bar
  '1 hour' => 3600,
  '3 hours' => 3*3600,
  '6 hours' => 6*3600,
  '12 hours' => 12*3600,
  '1 day' => 24*3600,
  '3 day' => 3*24*3600,
  '1 week' => 7*24*3600,
);

$CONF['nav_forecast'] = array( // forecast display
  '1 day' => 24*3600,
  '3 days' => 3*24*3600,
  '1 week' => 7*24*3600,
  '2 weeks' => 2*7*24*3600,
  '3 weeks' => 3*7*24*3600,
);
$CONF['nav_forecast_past_part'] = 0.1; // past part to show (percentage if < 1, otherwise: number of seconds)

$CONF['nav_scales'] = array( // proposed scales for resources
  'small' => 10,
  'big' => 20,
  'huge' => 40,
);

$CONF['nav_timeshifts'] = array( // proposed time-shifting buttons
  '1h' => 3600,
  '6h' => 6*3600,
  '1d' => 24*3600,
  '1w' => 7*24*3600,
);

$CONF['nav_filters'] = array( // proposed filters in the "misc" bar
  'all clusters' => 'resources.type = \'default\''',
  'cluster1 only' => 'resources.cluster=\'cluster1\''',
  'cluster2 only' => 'resources.cluster=\'cluster2\''',
  'cluster3 only' => 'resources.cluster=\'cluster3\''',
);

$CONF['nav_resource_bases'] = array( // proposed base resources
  'network_address',
  'cpuset',
);

$CONF['nav_timezones'] = array( // proposed timezones in the "misc" bar (the first one will be selected by default)
  'UTC',
  'Europe/Paris',
);

$CONF['nav_custom_buttons'] = array( // custom buttons, click opens the url in a new window
  'my label' => 'http://my.url'      // remove all lines to disable (empty array)
);

// Database access configuration
$CONF['db_server']="${cfg.database.host}";
$CONF['db_port']="5432"; // usually 5432 for PostgreSQL
$CONF['db_name']="${cfg.database.dbname}"; // OAR read only user account 
$CONF['db_user']="DB_BASE_LOGIN_RO";
$CONF['db_passwd']="DB_BASE_PASSWD_RO";
$CONF['db_max_job_rows']=20000; // max number of job rows retrieved from database, which can be handled.

// Data display configuration
$CONF['timezone'] = "UTC";
$CONF['site'] = "My OAR resources"; // name for your infrastructure or site
$CONF['resource_labels'] = array('network_address','cpuset'); // properties to describe resources (labels on the left). Must also be part of resource_hierarchy below 
$CONF['cpuset_label_display_string'] = "%02d";
$CONF['label_display_regex'] = array( // shortening regex for labels (e.g. to shorten node-1.mycluster to node-1
  'network_address' => '/^([^.]+)\..*$/',
  );
$CONF['label_cmp_regex'] = array( // substring selection regex for comparing and sorting labels (resources)
  'network_address' => '/^([^-]+)-(\d+)\..*$/',
  );
$CONF['resource_properties'] = array( // properties to display in the pop-up on top of the resources labels (on the left)
  'deploy', 'cpuset', 'besteffort', 'network_address', 'type', 'drain');
$CONF['resource_hierarchy'] = array( // properties to use to build the resource hierarchy drawing
  'network_address','cpuset',
  ); 
$CONF['resource_base'] = "cpuset"; // base resource of the hierarchy/grid
$CONF['resource_group_level'] = "network_address"; // level of resources to separate with blue lines in the grid
$CONF['resource_drain_property'] = "drain"; // if set, must also be one of the resource_properties above to activate the functionnality
$CONF['state_colors'] = array( // colors for the states of the resources in the gantt
  'Absent' => 'url(#absentPattern)', 'Suspected' => 'url(#suspectedPattern)', 'Dead' => 'url(#deadPattern)', 'Standby' => 'url(#standbyPattern)', 'Drain' => 'url(#drainPattern)');
$CONF['job_colors'] = array( // colors for the types of the jobs in the gantt
  'besteffort' => 'url(#besteffortPattern)', 
  'deploy(=\w)?' => 'url(#deployPattern)', 
  'container(=\w+)?' => 'url(#containerPattern)', 
  'timesharing=(\*|user),(\*|name)' => 'url(#timesharingPattern)', 
  'placeholder=\w+' => 'url(#placeholderPattern)',
  );
$CONF['job_click_url'] = '''; // set a URL to open when a job is double-clicked, %%JOBID%% is to be replaced by the jobid in the URL
$CONF['resource_click_url'] = '''; // set a URL to open when a resource is double-clicked, %%TYPE%% is to be replaced by the resource type and %%ID%% by the resource id in the URL

// Geometry customization
$CONF['hierarchy_resource_width'] = 10; // default: 10
$CONF['scale'] = 10; // default: 10
$CONF['text_scale'] = 10; // default: 10
$CONF['time_ruler_scale'] = 6; // default: 6
$CONF['time_ruler_steps'] = array(60,120,180,300,600,1200,1800,3600,7200,10800,21600,28800,43200,86400,172800,259200,604800);
$CONF['gantt_top'] = 50; // default: 50
$CONF['bottom_margin'] = 45; // default: 45
$CONF['right_margin'] = 30; // default 30
$CONF['label_right_align'] = 105; // default: 105
$CONF['hierarchy_left_align'] = 110; // default: 110
$CONF['gantt_left_align'] = 160; // default: 160
$CONF['gantt_min_width'] = 900; // default: 900
$CONF['gantt_min_height'] = 100; // default: 100
$CONF['gantt_min_job_width_for_label'] = 40; // default: 40
$CONF['min_state_duration'] = 2; // default: 2

// Colors and fill patterns for jobs and states
$CONF['job_color_saturation_lightness'] = "75%,75%"; // default: "75%,75%"
$CONF['job_color_saturation_lightness_highlight'] = "50%,50%"; // default: "50%,50%"
$CONF['static_patterns'] = <<<EOT
<pattern id="absentPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="10" height="10" viewBox="0 0 10 10" >
<polygon points="0,0 3,0 0,3" fill="#0000ff" stroke="#0000ff" stroke-width="1" />
<polygon points="7,0 10,0 10,3 3,10 0,10 0,7" fill="#0000ff" stroke="#0000ff" stroke-width="1" />
<polygon points="10,7 10,10 7,10" fill="#0000ff" stroke="#0000ff" stroke-width="1" />
</pattern> 
<pattern id="suspectedPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="10" height="10" viewBox="0 0 10 10" >
<polygon points="0,0 3,0 0,3" fill="#ff0000" stroke="#ff0000" stroke-width="1" />
<polygon points="7,0 10,0 10,3 3,10 0,10 0,7" fill="#ff0000" stroke="#ff0000" stroke-width="1" />
<polygon points="10,7 10,10 7,10" fill="#ff0000" stroke="#ff0000" stroke-width="1" />
</pattern> 
<pattern id="deadPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="10" height="10" viewBox="0 0 10 10" >
<polygon points="0,0 3,0 0,3" fill="#404040" stroke="#404040" stroke-width="1" />
<polygon points="7,0 10,0 10,3 3,10 0,10 0,7" fill="#404040" stroke="#404040" stroke-width="1" />
<polygon points="10,7 10,10 7,10" fill="#404040" stroke="#404040" stroke-width="1" />
</pattern> 
<pattern id="standbyPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="10" height="10" viewBox="0 0 10 10" >
<polygon points="0,0 3,0 0,3" fill="#88ffff" stroke="#88ffff" stroke-width="1" />
<polygon points="7,0 10,0 10,3 3,10 0,10 0,7" fill="#88ffff" stroke="#88ffff" stroke-width="1" />
<polygon points="10,7 10,10 7,10" fill="#88ffff" stroke="#88ffff" stroke-width="1" />
</pattern> 
<pattern id="drainPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="15" height="10" viewBox="0 0 10 10" >
<circle cx="5" cy="5" r="4" fill="#ff0000" stroke="#ff0000" stroke-width="1" />
<line x1="2" y1="5" x2="9" y2="5" stroke="#ffffff" stroke-width="2" />
</pattern> 
<pattern id="containerPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="20" height="20" viewBox="0 0 20 20" >
<text font-size="10" x="0" y="20" fill="#888888">C</text>
</pattern> 
<pattern id="besteffortPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="20" height="20" viewBox="0 0 20 20" >
<text font-size="10" x="10" y="20" fill="#888888">B</text>
</pattern> 
<pattern id="placeholderPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="20" height="20" viewBox="0 0 20 20" >
<text font-size="10" x="10" y="20" fill="#888888">P</text>
</pattern> 
<pattern id="deployPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="20" height="20" viewBox="0 0 20 20" >
<text font-size="10" x="10" y="10" fill="#888888">D</text>
</pattern> 
<pattern id="timesharingPattern" patternUnits="userSpaceOnUse" x="0" y="0" width="20" height="20" viewBox="0 0 20 20" >
<text font-size="10" x="10" y="20" fill="#888888">T</text>
</pattern> 
EOT;

// Standby state display options for the part shown in the future
$CONF['standby_truncate_state_to_now'] = 1; // default: 1
// Besteffort job display options for the part shown in the future
$CONF['besteffort_truncate_job_to_now'] = 1; // default: 1
$CONF['besteffort_pattern'] = <<<EOT
<pattern id="%%PATTERN_ID%%" patternUnits="userSpaceOnUse" x="0" y="0" width="10" height="10" viewBox="0 0 10 10" >
<polygon points="0,0 7,0 10,5 7,10 0,10 3,5" fill="%%PATTERN_COLOR%%" stroke-width="0"/>
</pattern>'
EOT;

// Advanced customization for the computation of the colors of the jobs
// Uncomment and adapt the following to override the default function
//class MyShuffle extends Shuffle {
//    // Default function: get the color's hue value as a function of the job_id
//    function job2int($job) {
//        // compute a suffled number for job_id, so that colors are not too close
//        $magic_number = (1+sqrt(5))/2;
//        return (int)(360 * fmod($job->job_id * $magic_number, 1));
//    }
//    // Other example: get the color's hue value as a function of the job_user value
//    protected $cache = array(); 
//    function job2int($job) { 
//        // shuffled number based on the job_user:
//        if (! array_key_exists($job->job_user, $this->cache)) {
//            $n = (int) base_convert(substr(md5($job->job_user) ,0, 5), 16, 10);
//            $magic_number = (1+sqrt(5))/2;
//            $this->cache[$job->job_user] = (int)(360 * fmod($n * $magic_number, 1));
//        }
//        return $this->cache[$job->job_user];
//    }
//}
//Shuffle::init(new MyShuffle()); // this line must be uncommented for the overiding to take effect

// Minimum timespan the gantt can handle
$CONF['min_timespan']= 480; // gantt does not show if (stop date - start date) < 8 minutes

// Debugging
$CONF['debug'] = 0; // Set to > 0 to enable debug prints in the web server error logs

?>
'';  
}
