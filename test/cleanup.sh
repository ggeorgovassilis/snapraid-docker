#!/bin/bash

umount workdir/data1
umount workdir/data2
umount workdir/data3
umount workdir/parity1

losetup --detach /dev/loop8
losetup --detach /dev/loop9
losetup --detach /dev/loop10
losetup --detach /dev/loop11
