function exit \
    --description "Disown all jobs started from this shell to avoid killing them on exit" \
    --on-event fish_exit
    jobs -q; and disown (jobs -p)
end
