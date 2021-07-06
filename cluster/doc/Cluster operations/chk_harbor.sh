#!/bin/bash

# To receive notify throught SLACK, modify APP_SLACK_WEBHOOK value and channel_name.
export APP_SLACK_WEBHOOK=https://hooks.slack.com/services
export APP_SLACK_USERNAME="cube"

HARBOR_DIR=/var/lib/cocktail/harbor

main() {
	cd $HARBOR_DIR
	cnt=$(/usr/local/bin/docker-compose ps | tail -n +3 | grep -v grep | grep Up | wc -l)

	if (( $cnt < "12" )); then
#       /var/lib/cocktail/scripts/slack.sh '#channel_name' test-cluster registry is unhealthy !!!.
        ret1=$(/usr/local/bin/docker-compose ps | tail -n +3)
        /usr/local/bin/docker-compose up -d
#        /var/lib/cocktail/scripts/slack.sh '#channel_name' test-cluster registry unhealthy components are restarted.
	fi

}

main "${@}"