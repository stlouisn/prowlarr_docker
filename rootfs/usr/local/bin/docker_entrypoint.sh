#!/bin/bash

#=========================================================================================

# Fix user and group ownerships for '/config'
chown -R prowlarr:prowlarr /config

# Delete PID if it exists
if
    [ -e "/config/prowlarr.pid" ]
then
    rm -f /config/prowlarr.pid
fi

#=========================================================================================

# Start prowlarr in console mode
exec gosu prowlarr \
    /Prowlarr/Prowlarr -nobrowser -data=/config
