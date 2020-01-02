#! /usr/bin/env bash


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

get_user_info() {
    curl --silent "$@" \
    --header "Authorization: Bearer $EVENTBRITE_PRIVATE_TOKEN" \
    'https://www.eventbriteapi.com/v3/users/me/'
}

get_user_id() {
    id_line=$( \
        get_user_info | \
        sed 's/, "/,\n"/g' | \
        grep \"id\": \
    )

    id_line=${id_line##* \"}
    echo ${id_line%\"*}
}

get_users_event_list() {
    curl --silent "$@" \
    --header "Authorization: Bearer $EVENTBRITE_PRIVATE_TOKEN" \
    'https://www.eventbriteapi.com/v3/organizations/150420679378/events/'
}

save_events_to_json() {
    get_users_event_list > "$@"
}


check_oauth_token
if [ -n "$1" ]; then
    save_events_to_json "$@"
fi