#!/bin/bash

##
# This test mounts 4 images with a pre-existing file system (just one file in each) as loop devices and mounts them under ./workdir
# as 3 data disks and one parity disk.
# After that it runs the snapraid container for an initial sync. Then one file on data2 is deleted, snapraid restores it.
# The test then verifies that the file was restored.
# Finally the test cleans up test volumes

set -e

workdir=""
loop_devices=( )

function setup_workdir () {
  random_file_name=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32)
  export workdir=/tmp/$random_file_name
  rm -rf $workdir
  mkdir -p $workdir/data1 $workdir/data2 $workdir/data3 $workdir/parity1
  cp -r images $workdir
}

function setup_image () {
  file=$1
  target=$2
  losetup -f "$file" > /dev/null
  loop_dev=$(losetup --associated "$file" | cut -f1 -d ':')
  mount -t ext4 "$loop_dev" "$target" > /dev/null
  echo "$loop_dev"
}

function teardown_loopdevices () {
	umount "$@"
	losetup --detach "$@"
}

function cleanup () {
	echo Cleaning up
	teardown_loopdevices "${loop_devices[@]}"
}

trap cleanup EXIT

function pause () {
	return 0
	echo Press ENTER
	read
}

function snapraid () {
	docker run --rm \
        --volume "$workdir/data1:/mnt/data1" \
        --volume "$workdir/data2:/mnt/data2" \
        --volume "$workdir/data3:/mnt/data3" \
        --volume "$workdir/parity1:/mnt/parity1" \
        --volume "$PWD/snapraid.conf:/etc/snapraid.conf:ro" \
        snapraid \
        /bin/snapraid "$@"
}

function setup () {
	setup_workdir

	loopdev1=$(setup_image $workdir/images/data1.img $workdir/data1)
	loopdev2=$(setup_image $workdir/images/data2.img $workdir/data2)
	loopdev3=$(setup_image $workdir/images/data3.img $workdir/data3)
	loopdev4=$(setup_image $workdir/images/parity1.img $workdir/parity1)

	export loop_devices=("$loopdev1" "$loopdev2" "$loopdev3" "$loopdev4")
}


setup
pause

echo Running snapraid sync
snapraid sync

echo Running snapraid scrub
snapraid scrub

echo Running snapraid status
snapraid status

testfile=$workdir/data2/data2

md5=$(md5sum $testfile)
echo Deleting $testfile

rm -rf $testfile

! [ -f $testfile ] && echo OK file missing, as expected || (echo FAIL file still exists && exit 1)

pause

echo Recovering $testfile

snapraid -d data2 -l fix.log fix
snapraid -d data2 -a check

pause

[ -f $testfile ] && echo OK file exists || (echo FAIL file not recovered && exit 1)

md5_n=$(md5sum $testfile)

[ "$md5" = "$md5_n" ] && echo OK contents are the same || (echo FAIL contents not the same && exit 1)
echo Deleting volumes

# not neccessary because trap EXIT will call cleanup
# cleanup
