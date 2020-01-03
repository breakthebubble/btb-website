#!./test/bats/bin/bats

EVENTBRITE_TEST_OUTPUT=./test/test_eventlist.json


setup() {
    source ./eventbrite.sh
}

teardown() {
    echo "###############################"
    echo "# Exit Status: $status" >&2
    echo "###############################"
    echo "# $output" >&2
    echo "###############################"
}


@test 'Env var for User Key' {
    echo "If this fails, get the generate an API key from the Eventbrite user settings."
    echo "run 'export EVENTBRITE_PRIVATE_TOKEN=>>put the key here<<'"
    [ -n "$EVENTBRITE_PRIVATE_TOKEN" ]
}

@test 'Exit if env var is not set' {
    skip # this test doesn't work.  Passes both ways
    unset $EVENTBRITE_PRIVATE_TOKEN
    run check_oauth_token
    [ "$status" -eq 0 ]
}

@test 'check good HTTP response' {
    run get_user_info --include
    [ "$status" -eq 0 ]
    [[ "$output" == *'HTTP/1.1 200 OK'* ]]
}

@test 'Get User Info' {
    run get_user_info
    # Good exit status
    [ "$status" -eq 0 ]
    # Contains ID
    [[ "$output" == *'"id": "'* ]]
    # Is only JSON
    [[ "$output" == "{"*"}" ]]
}

@test 'Get User ID' {
    run get_user_id
    [ "$status" -eq 0 ]
    # confirm output only contains digits
    [[ $output =~ ^[0-9]+$ ]]
}

@test 'Get Users Organizations' {
    run get_users_organizations
    [ "$status" -eq 0 ]
    echo $output > ./test/debug.json
    # Is only JSON
    [[ "$output" == "{"*"}" ]]
}

@test 'Get Users Event List' {
    run get_users_event_list
    # Good exit status
    [ "$status" -eq 0 ]
    # Contains events
    [[ "$output" == *'"events":'* ]]
    # Is only JSON
    [[ "$output" == "{"*"}" ]]
    # List matches current user
    [[ "$output" == *$(get_user_id)* ]]
}

@test 'Jekyll/Netlify Workaround: Filter HTML data' {
    skip  # checking in for now, while I branch
    event_data=$(get_users_event_list)
    [[ "$event_data" == *'<P>'* ]]
    run filter_json_html $event_data
    printf "\n\n$output" > ./test/filter.log
    [[ "$output" != *'<P>'* ]]
}

@test 'Clear output file' {
    rm -f ./test/test_eventbrite.json
}

@test 'Save JSON output' {
    run save_events_to_json $EVENTBRITE_TEST_OUTPUT
    # Exits with good status
    [ "$status" -eq 0 ]
    # Is only JSON
    echo $output > test_eventlist.json
    [[ "$(cat $EVENTBRITE_TEST_OUTPUT)" == "{"*"}" ]]
}








if [ -z "$EVENTBRITE_PRIVATE_TOKEN" ]; then
    echo
    echo "ERROR: The user's OAuth key is not set!"
    echo
    echo "1) Generate an API key from the Eventbrite user settings."
    echo "2) Run 'export EVENTBRITE_PRIVATE_TOKEN=>>put the key here<<'"
    exit 1
fi
