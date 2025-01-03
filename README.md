# snapraid-docker
Running snapraid in docker

# Installation

1. Check out this repository:

git clone https://github.com/ggeorgovassilis/snapraid-docker.git

2. Download a snapraid release (eg. at the point of writing from here https://github.com/amadvance/snapraid/releases/tag/v12.3), rename it to "snapraid.tar.gz" and place it in the "snapraid-docker" directory you checked out earlier

3. Build the docker image with:

./build.sh

This will take a while.

4. If the build succeeded, a quick test would be:

./snapraid.sh --version


5. By default, the script looks for /etc/snapraid.conf. An alternative file can be specified in the SNAPRAID_CONF environment variable. Paths in snapraid.conf must match the container side of volume mounts (eg. how the container sees them), not how they exist on the host machine.

6. Edit snapraid.sh volume mounts to match your setup. Ensure that volume mounts match paths in snapraid.conf
