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

status=false

while true
do 
    update="$(curl https://club.entropia.de | head -8 | tail -1 | tr -d ' ')"
    if [ "$update" != "$status" ]
    then 
        status="$update"
        curl -XPUT -d "{\"topic\": \"$update\"}" \
            "$provider/_matrix/client/r0/rooms/$room/state/m.room.topic?access_token=$token"
    fi
    sleep 300
done

