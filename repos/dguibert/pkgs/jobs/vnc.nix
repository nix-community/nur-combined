{ pkgs
, scheduler
}:
with pkgs; {
  job = scheduler.runJob {
    name = "vnc-${toString builtins.currentTime}";
    options = {
      partition="BDW-14c_edr_128gb_2400"; # to get the same check across partitions
      time="00:03:00";
      exclusive=false;
      ntasks="1";
    };
    buildInputs = [ pkgs.tigervnc pkgs.perl pkgs.xorg.xauth pkgs.openssh pkgs.xterm /*pkgs.virtualgl*/ ];
    script = ''
      ${figlet}/bin/figlet "Node Check"
      set -xuef -o pipefail
      echo job $SLURM_JOBID execution at: `date`
      # FIXME
      export HOME=/home_nfs_robin_ib/bguibertd
      export SHELL=/bin/bash

      # our node name
      NODE_HOSTNAME=`/usr/bin/hostname -s`
      echo "running on node $NODE_HOSTNAME"

      # VNC server executable
      VNCSERVER_BIN=`command -v vncserver`
      echo "using default VNC server $VNCSERVER_BIN"

      # set memory limits to 95% of total memory to prevent node death
      NODE_MEMORY=`/usr/bin/free -k | grep ^Mem: | awk '{ print $2; }'`
      NODE_MEMORY_LIMIT=`echo "0.95 * $NODE_MEMORY / 1" | /usr/bin/bc`
      ulimit -v $NODE_MEMORY_LIMIT -m $NODE_MEMORY_LIMIT
      echo "memory limit set to $NODE_MEMORY_LIMIT kilobytes"

      # Check whether a vncpasswd file exists.  If not, complain and exit.
      if [ \! -e $HOME/.vnc/passwd ] ; then
      	echo
      	echo "=================================================================="
      	echo "   You must run 'vncpasswd' once before launching a vnc session"
      	echo "=================================================================="
      	echo
      	exit 1
      fi

      # launch VNC session
      $VNCSERVER_BIN $@ 2> vnc.log
      VNC_DISPLAY=$(cat vnc.log | grep desktop | awk -F: '{print $3}')
      echo "got VNC display :$VNC_DISPLAY"

      if [ x$VNC_DISPLAY == "x" ]; then
          echo
          echo "===================================================="
          echo "   Error launching vncserver: $VNCSERVER"
          echo "   Please submit a ticket to the TACC User Portal"
          echo "   http://portal.tacc.utexas.edu/"
          echo "===================================================="
          echo
          exit 1
      fi

      LOCAL_VNC_PORT=`expr 5900 + $VNC_DISPLAY`
      echo "local (compute node) VNC port is $LOCAL_VNC_PORT"

      LOGIN_VNC_PORT="$VNC_DISPLAY`echo $NODE_HOSTNAME | perl -ne 'print "59$1" if /\d(\d\d)/;'`"
      echo "got login node VNC port $LOGIN_VNC_PORT"

      # create reverse tunnel port to login nodes.  Make one tunnel for each login so the user can just
      # connect to the frontend (when configured so)
      for i in `seq 0 0`; do
          ssh -f -g -N -R $LOGIN_VNC_PORT:$NODE_HOSTNAME:$LOCAL_VNC_PORT genji$i
      done
      echo "Created reverse ports on login node(s)"

      echo "Your VNC server is now running!"
      echo "ssh -L:$LOGIN_VNC_PORT:localhost:$LOGIN_VNC_PORT genji"
      echo "vncviewer localhost::$LOGIN_VNC_PORT"

      # set display for X applications
      export DISPLAY=":$VNC_DISPLAY"

      # we need vglclient to run to have graphics across multi-node jobs
      #vglclient >& /dev/null &
      #VGL_PID=$!

      # run an xterm for the user; execution will hold here
      xterm -r -ls -geometry 80x24+10+10 -title '*** Exit this window to kill your VNC server ***'

      # job is done!

      #echo "Killing VGL client"
      #kill $VGL_PID

      echo "Killing VNC server"
      vncserver -kill $DISPLAY

      # wait a brief moment so vncserver can clean up after itself
      sleep 1

      echo job $SLURM_JOB_ID execution finished at: `date`
    '';
  };
}
