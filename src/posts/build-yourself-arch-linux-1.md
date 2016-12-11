---
title: "Build Yourself Arch Linux"
date: November 21, 2016
---

# Part 1: Base System

This is the first part of (hopefully) series of articles on how I set up dual boot Arch Linux on my Mid 2014 MacBook Pro. At the end of this part I'll have a bootable but completely minimal installation of Arch on an encrypted partition without any tuning. Ability to boot to Mac OS will be preserved.

## Why?

I had the idea of going back to using Linux for some time now. It's hard for me to pinpoint a specific reasons for that. I've got feeling like I'm missing out lots of interesting stuff going on in the Linux world. Like the renaissance of containerisation and virtualization technologies, unikernels. While it's true that almost all of that is made available for Mac, it oftentimes feels like terrible hacks has been done to make it work. Also, I'm inclined to think that I haven't learned as much about computers as I could have during my time on OS X. I'm usually hesitant to learn proprietary things, well because of irrelevance of the knowledge outside of a cage. That way, I didn't get to know OS X itself that well. I have learned the other side of "just works" - the feeling of helplessness when things do not work.

[Latest Apple special event](http://www.apple.com/apple-events/october-2016/) was just enough bullshit I can take. Do whatever you want with your TouchBar and feedbackless keyboard, Apple, but I'm leaving. But I'm not going to throw the computer I've spent about $3K on, so here I am, installing Arch Linux on my MacBook.

Given the above arguments one may ask why not just install Ubuntu for example. While Ubuntu is a good system to start with (I've used it myself for about two years) I wanted to try something different this time. The primary reason to try Arch Linux is learning. I have learned _a lot_ when installing Arch Linux and writing this tutorial. The other thing is that I enjoy feeling of control over my machine. I like to know exactly what is installed and what is running on my computer, I don't want to be distracted by the stuff I do not use. Also I like the idea of [rolling release](https://en.wikipedia.org/wiki/Rolling_release). To be able to run the latest version of packages and the kernel is nice.

While there's no shortage of tutorials for installing Arch Linux on MacBook, everyone's case is different, so my experience may be useful to someone. I'm not intend to write an exhaustive tutorial with every command one will need to execute, but rather an outline with links to already existing materials and how my personal setup differs. Please follow an awesome [Installation guide](https://wiki.archlinux.org/index.php/Installation_guide) and [MacBook article](https://wiki.archlinux.org/index.php/MacBook) on ArchWiki, think and read (or at least skim through) man pages of unfamiliar commands. I'm not liable for any damage caused by my writings to your computer so be careful. Let's go.

## Preparing the installation

Before start you'll need to buy/borrow an Ethernet adapter for you Mac as WiFi probably won't work out of the box. It is possible to install Arch Linux using WiFi but I decided to skip the hassle. See [the wiki](https://wiki.archlinux.org/index.php/MacBookPro11,x#Wireless) if you're interested. Also, I would recommend to use an external display to no be blinded by your laptop's brightness during the installation. I'm going to keep OS X on my laptop for foreseeable future and dual boot into Arch Linux. If you do not intend to do that some parts of the installation process will be simpler (at least you would not have to worry about wiping the wrong partition).

To keep OS X partition untouched I needed to shrink it to make some space for Linux. I split my 256G storage in half by shrinking the partition using OS X. There're some hiccups: OS X El Capitan uses Core Storage Volumes by default and they are not easily resizeable. To resize the partition you'll need [convert it back](http://apple.stackexchange.com/a/139868/59256) to "native volume". Before conversion volume needs to be unencrypted, you'll have to turn FileVault off and wait a few ours until the disc will be decrypted. After that you can resize the OS X partition (using Disk Utils app or `diskutil` command) and turn FileVault back on.

First I had to [grab an Arch Linux ISO](https://www.archlinux.org/download/) which is around 800 MB. I always forget to verify downloads but it's better to not skip this step. Read [here](https://wiki.archlinux.org/index.php/Category:Getting_and_installing_Arch) how to verify the downloaded ISO using GPG. If you have no GPG installed, hashsums are better than nothing. The GPG signature and the checksums are available on the download page. Preparing installation USB is dead simple, see [the instructions](https://wiki.archlinux.org/index.php/USB_flash_installation_media#In_macOS). Reboot, hold Alt as soon as you hear startup sound and select your USB stick as a boot device. You're in Arch Linux installation shell now.

Before proceeding I needed to configure the installation environment a little bit. [Set font](https://wiki.archlinux.org/index.php/Fonts#Console_fonts) to something bigger (12x22) to be able actually see something (I use iso01-12x22). If you like me use something other than standard US layout, you'll need to [change the keymap](https://wiki.archlinux.org/index.php/Installation_guide#Set_the_keyboard_layout). Because I use [Workman layout](https://en.wikipedia.org/wiki/Keyboard_layout#Workman) I had to download a keymap for it from [GitHub](https://github.com/ojbucao/Workman). If you want to remap Caps Lock to Control immediately, edit your preferred keymap file and set keycode 58 to `Control` as I did [here](https://github.com/raindev/workman/blob/61fa62503af4322ab7d0559ced9a6201fbf7cac8/linux_console/workman.iso15.kmap#L62) for Workman. To download something from GitHub it is possible to use `elinks` browser from the shell. [Adjust the system clock](https://wiki.archlinux.org/index.php/Installation_guide#Update_the_system_clock) and lets continue onto the next step.

## Disk partition

I want to have full disk encryption enabled for my Linux partitions. To do that I've decided to go with LVM on LUKS as one from [available options](https://wiki.archlinux.org/index.php/Disk_encryption). It means that there's a single container encrypted using dm-crypt with LUKS and inside of the container there are multiple logical volumes managed by LVM. dm-crypt is the standard encryption functionality provided by the kernel itself and LUKS is a convenient utility to manage it. LVM is a flexible solution to manage logical partitions independently of the disk layout.

There's a [nice article](https://wiki.archlinux.org/index.php/Partitioning) on ArchWiki to help you decide what partition layout you want. I have settled on the following scheme: 20 GB for root partition; 12 GB for `/var` to prevent bewildered logs from eating up the space; 16 GB for swap partition; rest of the half of my 256 GB drive (68 GB in practice) are left for `/home`.

First we would need a partition for our LVM container. Use `fdisk -l` (or any other [partition tool](https://wiki.archlinux.org/index.php/Partitioning#Partitioning_tools)) to take a look at what layout you've got already. In my case I'm interested in `/dev/sda` half of it occupied by OS X as `/dev/sda1` and half of it free. I used `gdisk` to create a new partition of type `8E00` (Linux LVM). It was created as `/dev/sda2`. That's pretty much all I need from `gdisk`, all the LVM volumes will be leaving inside of container `/dev/sda2`. NB: Apple recommends to have 200Mb gap between partitions for possible future use, use `+200M` as a start sector of your new partition, if you want to. We're going to leave the existing [UEFI](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface) boot partition as is so you would not need to create a new one for `/boot`.

If you want to be secure, the newly created container partition needs to be [securely wiped](https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation#dm-crypt_wipe_on_an_empty_disk_or_partition) first. Please, try to not mistype your _empty_ partition number. [Here](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_disk_2) is how to initialize encrypted LUKS container and [slice it into partitions](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Preparing_the_logical_volumes). Skip sections about the boot partition as we have it already. I've initialized LUKS with default [encryption options](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode) as they seemed to roughly match what people recommend to use anyway. By this time you should have all the partitions mounted and formatted. Now mount your [ESP](https://wiki.archlinux.org/index.php/EFI_System_Partition) to `/mnt/boot`.

## Installing and configuring base system

First, check out if [list of mirror servers](https://wiki.archlinux.org/index.php/Installation_guide#Select_the_mirrors) looks sane. The highest priority servers were not from beyond an ocean and packages download speed was pretty high, so I'm fine with the defaults.

Now it's time to [markup the filesystem of your new OS and install the most necessary packages](https://wiki.archlinux.org/index.php/Installation_guide#Install_the_base_packages). If you want to be absolutely minimal and customize list of installed base packages, pass `-i` option to `pacstrap` and read [here](https://wiki.archlinux.org/index.php/Pacman#Installing_package_groups) about syntax used. I do not need nano, for example. To keep my modified version of Workman layout, I copied the `.kmap` file to `/mnt/usr/share/kbd/keymaps/`. One more thing to do before you'll switch into your brand new environment is to [generate fstab](https://wiki.archlinux.org/index.php/Installation_guide#Fstab).

Behold and [enter the brave new world](https://wiki.archlinux.org/index.php/Installation_guide#Chroot)! Configure [timekeeping](https://wiki.archlinux.org/index.php/Installation_guide#Time_zone), [font](https://wiki.archlinux.org/index.php/Fonts#Persistent_configuration), [locale and keyboard](https://wiki.archlinux.org/index.php/Installation_guide#Locale), [hostname](https://wiki.archlinux.org/index.php/Installation_guide#Hostname). To figure out if your hardware clock is indeed set to UTC compare `hwclock --utc` and `hwclock --localtime` (unless you live in UTC :P). Wired network should work out of the box and I'm going to configure WiFi later. [Set up root password](https://wiki.archlinux.org/index.php/Installation_guide#Root_password), it will be possible to create non root users later.

## initramfs

When computer is turned on the first thing that it runs is UEFI firmware. UEFI than launches an UEFI executable, systemd-boot boot manager that we will install later. systemd-boot is called "boot manager" and not "bootloader" because all it can do is to launch another UEFI applications from ESP. In our case it would be the Linux kernel. EFISTUB is a feature of newer kernels that allows it to act as an UEFI executable. Kernel than loads initramfs which is a set of prebuilt hooks to prepare the system to boot. After that actual OS boot starts from an init process, systemd in our case.

If root partition is encrypted so to be able to boot it needs to be decrypted first. To enable that [initramfs hooks](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio_2) are required. To use custom console font and keyboard layout to enter encrypted partition password add `consolefont` and `keymap` hooks before `encryption`. After mkinitcpio, the tool used to build initramfs, is reconfigured, initramfs needs to be [rebuild](https://wiki.archlinux.org/index.php/Installation_guide#Initramfs).

## Bootloader

[systemd-boot](https://wiki.archlinux.org/index.php/Systemd-boot) is a pretty simple boot manager to set up so I'll use it to start. Later I'd like to try rEFInd and its [beautiful themes](http://www.rodsbooks.com/refind/themes.html). Installation of systemd-boot comes down to `bootctl install`. [Here](https://wiki.archlinux.org/index.php/Systemd-boot#Configuration) is how to configure it. [This](https://wiki.archlinux.org/index.php/Systemd-boot#Encrypted_Root_Installations) section on booting from encrypted partition is of particular interest. Notable you'll need to add only Arch Linux entry by hands, OS X will be detected automatically at boot time based on the information available on ESP.

It is highly recommended to [enable CPU microcode updates](https://wiki.archlinux.org/index.php/Microcode) to ensure system stability. Don't forget to update systemd-boot Arch Linux entry. You should be able to verify that you did everything properly by searching for "microcode updated" in system startup log using `journalctl`.

Now you're ready to [reboot](https://wiki.archlinux.org/index.php/Installation_guide#Reboot) into your new shiny OS. On startup you should be presented with systemd-boot menu. After selecting Arch Linux and before boot you'll be presented with the prompt for your encryption password. After that you should see command line login prompt. Use `root` user for now.

## Caveats

While most of the things works as expected there're few hiccups worth mentioning. First I've noticed that `/var` fails to be unmounted on shutdown. It looks like the problem is with the partition being busy because it's used by systemd to write system shutdown logs. Quick search revealed that I'm not the only one having the problem unmounting separate `/var` partition and it should be forcibly unmounted by the end of shutdown process anyway. Still I'd like to make the unmounting error go.

Right now I have to type my password twice: once to unlock the encrypted partition and once to log in as a `root` user. To not have to do it twice I'm probably going to enable automatic login as a non-root user.

Be careful with doing anything while on battery as until suspend will be setup the machine will halt when run out of battery.

## Closing thoughts

If you will find any problems I've failed to mention or any mistakes while following this guide please email me about them and I'll update the post. I'll appreciate any suggestions for improvements.

In about a week or two I hope to post the second part of the guide. I'm going to focus on things like user and power management, wireless and continue to build the system upon the base I have.

## Credits

To write this guide I relied heavily on [ArchWiki](https://wiki.archlinux.org), and three tutorials by [Loïc Pefferkorn](http://loicpefferkorn.net/2015/01/arch-linux-on-macbook-pro-retina-2014-with-dm-crypt-lvm-and-suspend-to-disk/#dm-crypt-and-lvm:385892e3ac2613dca78d22bd09dbae7d), [Michael Chladek](https://mchladek.me/post/arch-mbp/) and [Ron A.](https://visual-assault.org/2016/03/05/install-encrypted-arch-linux-on-apple-macbook-pro/#boot-loader)
