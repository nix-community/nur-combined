#!/usr/bin/env bash

### AUTHOR:         Johann Birnick (github: jbirnick)
### PROJECT REPO:   https://github.com/jbirnick/waybar-timer

## FUNCTIONS

now () { date --utc +%s; }

killTimer () { rm -rf /tmp/waybar-timer ; }
timerSet () { [ -e /tmp/waybar-timer/ ] ; }
timerPaused () { [ -f /tmp/waybar-timer/paused ] ; }

timerExpiry () { cat /tmp/waybar-timer/expiry ; }
timerAction () { cat /tmp/waybar-timer/action ; }

secondsLeftWhenPaused () { cat /tmp/waybar-timer/paused ; }
minutesLeftWhenPaused () { echo $(( ( $(secondsLeftWhenPaused)  + 59 ) / 60 )) ; }
secondsLeft () { echo $(( $(timerExpiry) - $(now) )) ; }
minutesLeft () { echo $(( ( $(secondsLeft)  + 59 ) / 60 )) ; }

printExpiryTime () { notify-send -u low -r 12345 "Timer expires at $( date -d "$(secondsLeft) sec" +%H:%M)" ;}
printPaused () { notify-send -u low -r 12345 "Timer paused" ; }
removePrinting () { notify-send -C 12345 ; }

updateTail () {
  # check whether timer is expired
  if timerSet
  then
    if { timerPaused && [ $(minutesLeftWhenPaused) -le 0 ] ; } || { ! timerPaused && [ $(minutesLeft) -le 0 ] ; }
    then
      eval $(timerAction)
      killTimer
      removePrinting
    fi
  fi

  # update output
  if timerSet
  then
    if timerPaused
    then
      echo "{\"text\": \"$(minutesLeftWhenPaused)\", \"alt\": \"paused\", \"tooltip\": \"Timer paused\", \"class\": \"timer\" }"
    else
      echo "{\"text\": \"$(minutesLeft)\", \"alt\": \"running\", \"tooltip\": \"Timer expires at $( date -d "$(secondsLeft) sec" +%H:%M)\", \"class\": \"timer\" }"
    fi
  else
    echo "{\"text\": \"0\", \"alt\": \"standby\", \"tooltip\": \"No timer set\", \"class\": \"timer\" }"
  fi
}

## MAIN CODE

case $1 in
  updateandprint)
    updateTail
    ;;
  new)
    killTimer
    mkdir /tmp/waybar-timer
    echo "$(( $(now) + 60*${2} ))" > /tmp/waybar-timer/expiry
    echo "${3}" > /tmp/waybar-timer/action
    printExpiryTime
    ;;
  increase)
    if timerSet
    then
      if timerPaused
      then
        echo "$(( $(secondsLeftWhenPaused) + ${2} ))" > /tmp/waybar-timer/paused
      else
        echo "$(( $(timerExpiry) + ${2} ))" > /tmp/waybar-timer/expiry
        printExpiryTime
      fi
    else
      exit 1
    fi
    ;;
  cancel)
    killTimer
    removePrinting
    ;;
  togglepause)
    if timerSet
    then
      if timerPaused
      then
        echo "$(( $(now) + $(secondsLeftWhenPaused) ))" > /tmp/waybar-timer/expiry
        rm -f /tmp/waybar-timer/paused
        printExpiryTime
      else
        secondsLeft > /tmp/waybar-timer/paused
        rm -f /tmp/waybar-timer/expiry
        printPaused
      fi
    else
      exit 1
    fi
    ;;
  *)
    echo "Please read the manual at https://github.com/jbirnick/waybar-timer ."
    ;;
esac
