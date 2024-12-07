#!/bin/sh
if  [ -z "$MATRIX_PROVIDER" ] || 
    [ -z "$MATRIX_ACCESS_TOKEN" ] || 
    [ -z "$MATRIX_ROOM_ID" ]
then
    echo 'env vars $MATRIX_PROVIDER or $MATRIX_ACCESS_TOKEN or $MATRIX_ROOM_ID not set'
    exit -1
fi

provider="$MATRIX_PROVIDER"
token="$MATRIX_ACCESS_TOKEN"
room="$MATRIX_ROOM_ID"

previous_status="?"
mosquitto_sub -h mqtt.club.entropia.de -t /public/eden/clubstatus -q 2 -I status-bot |
    while read update ; do
        if [ "$update" != "$previous_status" ]
        then 
            previous_status="$update"
            message="Club status unknown"
            if [ "$update" = "1" ] ; then
              message="Club is now open"
            fi
            if [ "$update" = "0" ] ; then
              message="Club is now closed"
            fi
            curl -XPUT -d "{\"topic\": \"$message\"}" \
                "$provider/_matrix/client/r0/rooms/$room/state/m.room.topic?access_token=$token"
            curl \
                -H "Title: Entropia status updates" \
                -H "Priority: low" \
                -H "Tags: wave" \
                -H "Icon: https://entropia.de/images/d/d0/Entropia_Transparent_Farbe_HighRes.png" \
                -d "$message" \
                ntfy.sh/entropia
        fi
    done
