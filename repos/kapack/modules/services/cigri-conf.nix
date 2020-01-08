{pkgs, lib, cfg}:
with lib;
let

  baseConfString = ''
# Database settings
# TYPE may be Pg or Mysql
DATABASE_TYPE = "Pg" 
DATABASE_HOST = "${cfg.server.host}"
DATABASE_NAME = "${cfg.database.dbname}"

# Where is CiGri installed
INSTALL_PATH = "${cfg.package}/share/cigri/"

# Timeout in seconds for jobs remaining in the waiting status on the clusters
# or in the cigri queues
REMOTE_WAITING_TIMEOUT = "900"

# How often to re-check some events before trying to fix
AUTOFIX_DELAY = "30"

# Default resources when jobs do not define otherwise
DEFAULT_JOB_RESOURCES = "/resource_id=1"

# Default walltime given to the jobs
DEFAULT_JOB_WALLTIME = "01:00:00"

# Stress factor above which a cluster is considered under stress
# (meaning we should stop queuing jobs until the stress factor becomes
# again acceptable). Note that a cluster under stress is not blacklisted
# so that we can still update job statuses.
STRESS_FACTOR="0.8"

#############################################################################
## LOGGING OPTIONS
#############################################################################
#File where to log (STDOUT AND STDERR are accepted as  well)
LOG_FILE = "${cfg.server.logfile}"
# loglevel as supported by the ruby logger (FATAL, ERROR, WARN, INFO, DEBUG)
LOG_LEVEL = "INFO"
# Job debugging. Set to 1 if you want to dump all submitted jobs
LOG_JOBS = "0"
LOG_JOBS_DIRECTORY = "/var/log/cigri_jobs"
# Number of lines to get from the end of the stderr file of a cluster job
# This is passed as a "tail=<STDERR_TAIL>" argument to get_file query.
STDERR_TAIL = 5

#############################################################################
## REST CLIENT OPTIONS
#############################################################################
# Timeout in seconds, for all rest queries to the clusters
REST_QUERIES_TIMEOUT="25"
# Certificate file used for rest queries to the clusters
# The certificate must be signed by a CA that is trusted by the OAR API of
# the clusters.
REST_CLIENT_CERTIFICATE_FILE="/etc/cigri/ssl/cigri.crt"
# Key file used for rest queries to the clusters
REST_CLIENT_KEY_FILE="/etc/cigri/ssl/cigri.key"
# The 2 following options are there if you want to enforce security
# by checking the validity of the clusters rest api certificates.
# Certificate authority file
#REST_CLIENT_CA_FILE="/etc/cigri/ssl/ca.cert"
# Verify ssl option
#REST_CLIENT_VERIFY_SSL="OpenSSL::SSL::VERIFY_PEER"

#############################################################################
## RUNNER OPTIONS
#############################################################################
# Minimum cycle duration
# The runner sleeps this time of seconds if necessary to prevent
# from looping too fast and let the time to clusters for jobs digestion
RUNNER_MIN_CYCLE_DURATION = "15"
# Default initial number of jobs to submit
# The runner submits several jobs at a time using oar array jobs.
# This number specifies the initial number of jobs to submit. Then,
# the runner may decide to increase or decreseases this number.
RUNNER_DEFAULT_INITIAL_NUMBER_OF_JOBS = "3" 
# Increase (or decrease) the number of jobs submitted at each succesful cycle
# by this value 
RUNNER_TAP_INCREASE_FACTOR = "1.5"
# Maximum number of jobs submitted by a runner cycle (maximum
# array job size)
RUNNER_TAP_INCREASE_MAX = "100"
# Grace period for a closed tap: when a tap is closed, it is maybe just
# beacuse the cluster needs some time to pass the jobs to the running state.
# So, we don't directly try the next campaign, but wait a bit.
# The value is a number of seconds.
RUNNER_TAP_GRACE_PERIOD = "60"

#############################################################################
## API OPTIONS
#############################################################################
# Header variable where username is given to the API (configured in apache 
# configuration)
API_HEADER_USERNAME="HTTP_X_CIGRI_USER"

#############################################################################
## NOTIFICATION OPTIONS
#############################################################################
#### MAIL notifications ####
# Smtp server
# If this variable is not set, mail notifications are disabled
#NOTIFICATIONS_SMTP_SERVER="smtp.imag.fr"
# Port of the smtp server
#NOTIFICATIONS_SMTP_PORT="25"
# From identity
#NOTIFICATIONS_SMTP_FROM="cigri@please.configure.me"
# Subject tag
# This is a small string that will be prefixed to the subject
#NOTIFICATIONS_SMTP_SUBJECT_TAG="[CIGRI]"
#### XMPP notifications ####
# Xmpp server
# If this variable is not set, xmpp notifications are disabled
#NOTIFICATIONS_XMPP_SERVER="talk.google.com"
# Port of the xmpp server
#NOTIFICATIONS_XMPP_PORT="5222"
# Xmpp identity
#NOTIFICATIONS_XMPP_IDENTITY=""
# Xmpp password
#NOTIFICATIONS_XMPP_PASSWORD=""

#############################################################################
## MISC OPTIONS
#############################################################################
#
# Minimum duration in seconds between two updates of the grid_usage table
# This table is maintained only for making statistics and informations to the 
# users. Set to 0 to disable.
GRID_USAGE_UPDATE_PERIOD="60"
# Dirty wait for maximizing chances of gridusage processes synchro
# Ignored if GRID_USAGE_UPDATE_PERIOD is set to 0
GRID_USAGE_SYNC_TIME="10"
  '';

vars =  mapAttrsToList (name: value: name) cfg.extraConfig;
commentedVars = map (value: "#" + value) vars;

cigriBaseConfString = replaceStrings vars commentedVars baseConfString;

settingsString = concatStrings (lib.mapAttrsToList (n: v: ''${n}="${toString v}"'' + "\n") cfg.extraConfig);

in
{
  cigriBaseConf = pkgs.writeText "cigri-base.conf"  (cigriBaseConfString + settingsString);
  
  cigriApiClientsConf =  pkgs.writeText "api-clients.conf" (concatStringsSep "\n" [
  ''
    API_HOST = "${cfg.server.host}"
    API_PORT = "${toString cfg.server.api_port}"
    API_TIMEOUT = "60"
    API_BASE = "${cfg.server.api_base}"
  '' 
  (optionalString (cfg.server.api_SSL) ''
    API_SSL = "true"
    API_VERIFY_SSL="OpenSSL::SSL::VERIFY_NONE"  
  '')]);
  
  unicornConfig = pkgs.writeText "unicorn.rb" ''
    worker_processes 2

    listen ENV["UNICORN_PATH"] + "/tmp/sockets/cigri.socket", :backlog => 64

    working_directory ENV["CIGRI_API_PATH"]

    timeout 60

    # Set process id path
    pid ENV["UNICORN_PATH"] + "/tmp/pids/unicorn.pid"

    # Set log file paths
    stderr_path ENV["UNICORN_PATH"] +"/log/unicorn.stderr.log"
    stdout_path ENV["UNICORN_PATH"] +"/log/unicorn.stdout.log"
  '';
  
}
