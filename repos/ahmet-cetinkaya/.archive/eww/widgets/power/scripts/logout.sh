#!/bin/bash

# Script to logout the current user
(loginctl terminate-user $(whoami) || pkill -KILL -u $(whoami))