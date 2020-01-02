#! /usr/bin/env bash

get_user_info() {
    #echo $( \
        curl --silent "$@" \
        --header "Authorization: Bearer $EVENTBRITE_PRIVATE_TOKEN" \
        'https://www.eventbriteapi.com/v3/users/me/'
    #)
}

check_oauth_token() {
    if [ -z "$EVENTBRITE_PRIVATE_TOKEN" ]; then
        echo
        echo "ERROR: The user's OAuth key is not set!"
        echo
        echo "1) Generate an API key from the Eventbrite user settings."
        echo "2) Run 'export EVENTBRITE_PRIVATE_TOKEN=>>put the key here<<'"
        exit 1
    fi
}


check_oauth_token
