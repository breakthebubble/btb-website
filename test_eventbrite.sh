#!./test/bats/bin/bats


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

@test 'Clear the log file' {
    echo > curl.log
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
#    echo "$output" >> curl.log #&3
    
    [[ "$output" == *'HTTP/1.1 200 OK'* ]]
}

@test 'Get User ID' {
    run get_user_info
    echo "$output" >> curl.log #&3
    [ "$status" -eq 0 ]

    [[ "$output" == *'"id": "'* ]]
}

@test 'Returns only JSON' {
    run get_user_info
    echo "$output" >> curl.log #&3
    [[ "$output" == "{"*"}" ]]
}


if [ -z "$EVENTBRITE_PRIVATE_TOKEN" ]; then
    echo
    echo "ERROR: The user's OAuth key is not set!"
    echo
    echo "1) Generate an API key from the Eventbrite user settings."
    echo "2) Run 'export EVENTBRITE_PRIVATE_TOKEN=>>put the key here<<'"
    exit 1
fi
