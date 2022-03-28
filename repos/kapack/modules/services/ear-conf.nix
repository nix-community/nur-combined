{pkgs, lib, cfg}:
with lib;
let
  useMysql = cfg.database.type == "mysql";
  baseConfString = ''
# EAR Configuration File
#---------------------------------------------------------------------------------------------------
# DB confguration: This configuration conrrespondons with the DB server installation
#---------------------------------------------------------------------------------------------------
DBIp=${cfg.database.host}
#DBUser=ear_daemon
#DBPassw=password
# User and password for usermode querys.
#DBCommandsUser=ear_commands
#DBCommandsPassw=password
DBDatabase=${cfg.database.dbname}
DBPort= ${if useMysql then "3306" else "5432"}
#---------------------------------------------------------------------------------------------------
# EAR Daemon (EARD) : Update that section to change EARD configuration
#---------------------------------------------------------------------------------------------------
## Port is used for connections with the EAR plugin and commands
NodeDaemonPort=50001
# Frequency at wich the periodic metrics are reported: In seconds
NodeDaemonPowermonFreq=60
# Enables the use of the database.
NodeUseDB=1
# Inserts data to MySQL by sending that data to the EARDBD (1) or directly (0).
NodeUseEARDBD=1
# The verbosity level [0..4]
NodeDaemonVerbose=4

# When set to 1, the output is saved in '$EAR_TMP'/eard.log (common configuration) as a log file.Otherwsie, stderr is used.
NodeUseLog=1

#---------------------------------------------------------------------------------------------------
# EAR Database Manager (EARDBD): Update that section to change EARDBD configuration
#---------------------------------------------------------------------------------------------------
DBDaemonPortTCP=50002
DBDaemonPortSecTCP=50003
DBDaemonSyncPort=50004
# In seconds
DBDaemonAggregationTime=60
DBDaemonInsertionTime=30
# Memory size expressed in MB per process (server and/or mirror) to cache the values.
DBDaemonMemorySize=120

#---------------------------------------------------------------------------------------------------
# EAR Library (EARL)
#---------------------------------------------------------------------------------------------------
CoefficientsDir=/etc/ear/coeffs

#---------------------------------------------------------------------------------------------------
# EAR Global Manager (EARGMD) : Update that section to use EARGM 
#---------------------------------------------------------------------------------------------------
EARGMHost=${cfg.eargmHost}
# Use aggregated periodic metrics or periodic power metrics. Aggregated metrics are only available
# when EARDBD is running
EARGMUseAggregated=1
# Period T1 and T2 are specified in seconds T1 (ex. must be less than T2, ex. 10min and 1 month)
EARGMPeriodT1=60
EARGMPeriodT2=259200
# '-' are Joules, 'K' KiloJoules and 'M' MegaJoules.
EARGMUnits=K
EARGMEnergyLimit=550000
EARGMPort=50000
# Two modes are supported '0=manual' and '1=automatic'.
EARGMMode=0
# T1 "grace" periods between DEFCON before re-evaluate.
EARGMGracePeriods=3
# Format for action is: command_name energy_T1 energy_T2  energy_limit T2 T1  units "
# This action is automatically executed at each warning level (only once per grace periods)
EARGMEnergyAction=no_action

#### POWERCAP definition for EARGM: Powercap is still under development. Do not activate
# 0 means no powercap
EARGMPowerLimit=0
# Period at which the powercap thread is activated
EARGMPowerPeriod=120
# 1 means automatic, 0 is only monitoring
EARGMPowerCapMode=0
# Admins can specify to automatically execute a command in EARGMPowerCapSuspendAction when total_power >= EARGMPowerLimit*EARGMPowerCapResumeLimit/100
EARGMPowerCapSuspendLimit=90
# Format for action is: command_name current_power current_limit total_idle_nodes total_idle_power 
EARGMPowerCapSuspendAction=no_action
# Admins can specify to automatically execute a command in EARGMPowerCapResumeAction to undo EARGMPowerCapSuspendAction
# when total_power >= EARGMPowerLimit*EARGMPowerCapResumeLimit/100. Note that this will only be executed if a suspend action was executed previously.
EARGMPowerCapResumeLimit=40
# Format for action is: command_name current_power current_limit total_idle_nodes total_idle_power 
EARGMPowerCapResumeAction=no_action

EARGMVerbose=4

#---------------------------------------------------------------------------------------------------
# Common configuration
#---------------------------------------------------------------------------------------------------
TmpDir=/var/lib/ear
EtcDir=/etc/ear
InstDir=${pkgs.nur.repos.kapack.ear}
# Network extension (using another network instead of the local one). If compute nodes must be accessed from login nodes with a network different than default, and can be accesed using a expension, uncommmet next line and define 'netext' accordingly. 
# NetworkExtension=netext

# Default verbose level
Verbose=4

#---------------------------------------------------------------------------------------------------
# Plugin configuration. These values are used for the whole cluster except a specific configuration is
# explicitly applied to one tag. They are mandatory since they are used by default 
#---------------------------------------------------------------------------------------------------
## Energy readings sources: List of plugins available at $EAR_INSTALL_PATH/lib/plugins/energy
energy_plugin=${cfg.energyPlugin}
## Energy models: List of plugins available at $EAR_INSTALL_PATH/lib/plugins/models
energy_model=${cfg.energyModel}
## Powercap plugins: List of plugins available at $EAR_INSTALL_PATH/lib/plugins/powercap
powercap_plugin=${cfg.powercapPlugin}

#---------------------------------------------------------------------------------------------------
# Authorized Users
#---------------------------------------------------------------------------------------------------
# Authorized users,accounts and groups are allowed to change policies, thresholds, frequencies etc,
# they are supposed to be admins, all special name is supported
#AuthorizedUsers=user1,user2
#AuthorizedAccounts=acc1,acc2,acc3
#AuthorizedGroups=grp1,grp2

#---------------------------------------------------------------------------------------------------
# Tags
#---------------------------------------------------------------------------------------------------
# Tags are used for architectural descriptions. Max. AVX frequencies are used in predictor models
# and are SKU-specific. Max. and min. power are used for warning and error tracking. 
# Powercap specifies the maximum power a node is allowed to use by default. If EARGM is actively
# monitoring the cluster's powercap, max_powercap can be used to ensure that a node's power will never
# go beyond that value, regardless of the free power available cluster-wide.
# At least a default tag is mandatory to be included in this file for a cluster to work properly.
Tag=foo default=yes max_avx512=2.1 max_avx2=2.1 max_power=500 min_power=1 error_power=600 coeffs=coeffs.default powercap=0
#Tag=6126 max_avx512=2.3 max_avx2=2.9 ceffs=coeffs.6126.default max_power=600 error_power=700 powercap=0

#---------------------------------------------------------------------------------------------------
## Power policies
## ---------------------------------------------------------------------------------------------------
#
## policy names must be exactly file names for policies installed in the system
DefaultPowerPolicy=monitoring
#Policy=monitoring Settings=0 DefaultFreq=2.1 Privileged=0
#Policy=min_time Settings=0.7 DefaultFreq=2.0 Privileged=0
#Policy=min_energy Settings=0.05 DefaultFreq=2.4 Privileged=1

# For homogeneous systems, default frequencies can be easily specified using freqs, for heterogeneous systems it is preferred to use pstates or use tags 

# Example with pstates (lower pstates corresponds with higher frequencies). Pstate=1 is nominal and 0 is turbo
Policy=monitoring Settings=0 DefaultPstate=1 Privileged=0
Policy=min_time Settings=0.7 DefaultPstate=4 Privileged=0
Policy=min_energy Settings=0.05 DefaultPstate=1 Privileged=0

#Example with tags
#Policy=monitoring Settings=0 DefaultFreq=2.6 Privileged=0 tag=6126
#Policy=min_time Settings=0.7 DefaultFreq=2.1 Privileged=0 tag=6126
#Policy=min_energy Settings=0.05 DefaultFreq=2.6 Privileged=1 tag=6126
#Policy=monitoring Settings=0 DefaultFreq=2.4 Privileged=0 tag=6148
#Policy=min_time Settings=0.7 DefaultFreq=2.0 Privileged=0 tag=6148
#Policy=min_energy Settings=0.05 DefaultFreq=2.4 Privileged=1 tag=6148

#---------------------------------------------------------------------------------------------------
# Energy Tags
#---------------------------------------------------------------------------------------------------
# Privileged users,accounts and groups are allowed to use EnergyTags. The "allowed" TAGs are defined
# by row together with the priviledged user/group/account.
#EnergyTag=cpu-intensive pstate=1
#EnergyTag=memory-intensive pstate=4 users=usr1,usr2 groups=grp1,grp2 accounts=acc1,acc2

#---------------------------------------------------------------------------------------------------
# Node Isles
#---------------------------------------------------------------------------------------------------
# It is mandatory to specify all the nodes in the cluster, grouped by islands. More than one line
# per island must be supported to hold nodes with different names or for pointing to different
# EARDBDs through its IPs or hostnames.
#
# In the following example the nodes are clustered in two different islands, but the Island 1 have
# two types of EARDBDs configurations. 
#Island=0 Nodes=node[1-2] DBIP=eardb

# These nodes are in island0 using different DB connections and with a different architecture
#Island=0 Nodes=node11[01-80] DBIP=node1084 DBSECIP=node1085 tag=6126 
# These nodes are is island0 and will use default values for DB connection (line 0 for island0) and default tag
#Island=0 Nodes=node1[1-2]

# Will use default tag 
#Island=1 Nodes=node11[01-80] DBIP=node1181 DBSECIP=node1182 
'';
vars =  mapAttrsToList (name: value: name) cfg.extraConfig;
commentedVars = map (value: "#" + value) vars;

earBaseConfString = replaceStrings vars commentedVars baseConfString;

settingsString = concatStrings (lib.mapAttrsToList (n: v: ''${n}=${toString v}'' + "\n") cfg.extraConfig);

in
{
  earBaseConf = pkgs.writeText "ear-base.conf"  (earBaseConfString + settingsString);
}
