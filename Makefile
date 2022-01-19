## The purpose of this file is to bundle up all CLI invocations into
## one self-documenting executable script.

## "Fakefile" boilerplate: BEGIN

# Color-formatting vars:
ifdef COLORTERM
  ANSI_NORM := \033[0m
  ANSI_BOLD := \033[1m
  ANSI_RED  := \033[31m
  ANSI_CYAN := \033[36m
endif

.PHONY: %
all: %
%:;	@ echo "$@: try 'make help'"

printvar-%: ## print a Makefile or env var. Replace '%' with var name. May be repeated.
	@ echo $*='$($*)'

help:: ## help for this Makefile
	@ printf "$(ANSI_BOLD)$(ANSI_RED)%s$(ANSI_NORM)\n" 'Available commands:'
	@ awk -F ":.*?## " \
		'/^[[:graph:]]+:.*?## .*$$/{printf "$(ANSI_CYAN)%-25s$(ANSI_NORM) %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST) \
		| sort

## "Fakefile" boilerplate: END

## command "goals"

compose-up::               ## start up containers
	@ docker compose up; true

compose-down::             ## shut down containers
	@ docker compose down

docker-clean::             ## purge container build
	@ docker rmi collect_nginx

docker-build::             ## build docker image
	@ docker build -t nginx_local .

docker-run::               ## run docker container
	@ docker run --name nginx -d nginx_local

docker-run-rm::            ## run ephemeral docker container
	@ docker run --name nginx -d nginx_local --rm

docker-shell-%::           ## shell into container. ex: docker-shell-nginx or docker-shell-redis
	@ docker exec -it $* /bin/sh; true

mock-requests::            ## generate randomized requests
	@ ./mock_requests.py

mock-single-request::      ## generate a single request
	@ curl "http://0.0.0.0:8080/collect?cid=$$(uuidgen | tr A-Z a-z)"

mock-single-request-%::    ## above, with an arbitrary unix timestamp. ex: $(gdate +%s -d "$((RANDOM%60)) days ago")
	@ curl "http://0.0.0.0:8080/collect?cid=$$(uuidgen | tr A-Z a-z)&d=$*"

uniques-clean::            ## clear out redis data
	@  rm -v ./redis_data/dump.rdb

uniques-daily::            ## check today's uniques
	@ curl 'http://0.0.0.0:8080/daily_uniques'

uniques-daily-%::          ## check a specific date's uniques. ex: uniques-daily-20211225
	@ curl "http://0.0.0.0:8080/daily_uniques?d=$*"

uniques-monthly::          ## check last 30 days uniques
	@ curl 'http://0.0.0.0:8080/monthly_uniques'

uniques-monthly-%::        ## check 30 days before a specific date. ex: uniques-monthly-20211225
	@ curl "http://0.0.0.0:8080/monthly_uniques?d=$*"

# vim: tabstop=2 shiftwidth=2 :
