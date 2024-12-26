#!/bin/bash
[[ -z "${SNAPRAID_CONF+x}" ]] && SNAPRAID_CONF="/etc/snapraid.conf"
docker run --rm \
	--volume "$SNAPRAID_CONF:/etc/snapraid.conf:ro" \
	--volume /mnt/snapraid:/mnt/snapraid \
	snapraid snapraid "$@"
 
