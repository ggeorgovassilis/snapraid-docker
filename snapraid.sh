#!/bin/bash
[[ -z "${SNAPRAID_CONF+x}" ]] && SNAPRAID_CONF="snapraid.conf"
docker run --rm \
	--volume /etc/snapraid.conf:/etc/snapraid.conf:ro \
	--volume /mnt/snapraid:/mnt/snapraid \
	snapraid snapraid "$@"
 
