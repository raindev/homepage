+++
title = "How to Partition an External Hard Drive for macOS"
date = 2017-06-15
aliases = [ "hdd-for-macos.html" ]
+++

TL;DR macOS expects 200 MB EFI System partition in the beginning of a hard drive, don't like unformatted partitions and creates 128 MB Apple boot partitions after each real partition whenever you format it.

I needed to partition an external hard drive to be usable on macOS (for [Time Machine](https://en.wikipedia.org/wiki/Time_Machine_(macOS)) backups). I've partitioned the drive using [GPT](https://en.wikipedia.org/wiki/GUID_Partition_Table) scheme and created one unformatted Apple HFS/HFS+ partition on Arch Linux using [fdisk](https://wiki.archlinux.org/index.php/Fdisk). It was not recognized (the inserted disk is not readable dialogue), nor was I able to format the partition (with "Media kit reports not enough space on device" error) which was shown as full in the Disk Utility. When I have formatted the partition (using mkfs.hfsplus from [hfsprogs](https://www.archlinux.org/packages/community/x86_64/hfsprogs/)) the partition was recognized but I was unable to initialize it for Time Machine or format with the same error as before. Finally I have partitioned the drive from macOS and created a new partition. Looking at the drive with fdisk I've discovered that EFI System partition was created in the beginning of the disk with size of 200MB. When I have recreated the same partitioning layout using fdisk it was recognized properly. After setting up Time Machine backups on the created partition I have inspected the disk once more. The partition type was changed to Apple core storage and a 128 MB partition was created after it. When I created another partition for the second MacBook I got one more 125 MB Apple boot partition. The resulting partition table was:

```
Device         Start       End   Sectors  Size Type
/dev/sdb1       2048    411647    409600  200M EFI System
/dev/sdb2     411648 268847103 268435456  128G Apple Core storage
/dev/sdb3  268847104 269109247    262144  128M Apple boot
/dev/sdb4  269109248 478824447 209715200  100G Apple Core storage
/dev/sdb5  478824448 479086591    262144  128M Apple boot
```

So 5 partitions instead of 2 I actually needed. [Here](https://developer.apple.com/library/content/technotes/tn2166/_index.html#//apple_ref/doc/uid/DTS10003927-CH1-SUBSECTION5) Apple's partitioning policy can be found describing when additional partitions are created with some justifications trying to answer why they are needed.
