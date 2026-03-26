#!/usr/bin/env bash

# Switch between available audio outputs.

query=$(
cat <<EOF
    .[]
    | select(.type == "PipeWire:Interface:Metadata")
    | .metadata.[]
    | select(.key == "default.configured.audio.sink")
    | .value.name
EOF
)

active_sink_name=$(pw-dump | jq -r "$query")

query=$(
cat <<EOF
    [
        .[]
        | select(.info.props."media.class" == "Audio/Sink")
        | select(.info.props."node.name" == "${active_sink_name}")
    ]
    | .[].id
EOF
)

active_sink=$(pw-dump | jq -r "$query")

query=$(
cat <<EOF
    [
        .[]
        | select(.info.props."media.class" == "Audio/Sink")
        | select(
            .info.props."node.name"
            | test("(?i)HDMI")
            | not
        )
    ]
    | .[].id
EOF
)

mapfile -t available_sinks <<<"$(pw-dump | jq -r "$query")"

if [[ "${available_sinks[-1]}" == "$active_sink" ]]; then
    wpctl set-default "${available_sinks[0]}"
    exit 0
fi

for i in "${!available_sinks[@]}"; do
    if [[ "${available_sinks[$i]}" = "$active_sink" ]]; then
        wpctl set-default "${available_sinks[$i+1]}"
        exit 0
    fi
done

wpctl set-default "${available_sinks[0]}"
