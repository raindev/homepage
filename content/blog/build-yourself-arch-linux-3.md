+++
title = "Build Yourself Arch Linux, Part 3"
date = 2017-10-11
+++

# Part 3: Let's Get a GUI

This is the third and the final part of my Build Yourself Arch Linux series ([part 1](/blog/build-yourself-arch-linux-1), [part 2](/blog/build-yourself-arch-linux-2)). In this part I'll finally get to a graphical environment setup.

## GNOME

Before settling down on [GNOME](https://gnome.org/) I've tried (well installed and played around for 10 minutes) most of [the desktop environments supported by Arch](https://wiki.archlinux.org/index.php/Desktop_environment#List_of_desktop_environments). I've been using GNOME 3 in the past but decided to look what else is out there. The reason I've settled on GNOME now is HiDPI support. While there're other desktop environments that support HiDPI GNOME gave me the best result with pretty much no configuration. I was really tempted by [KDE Plasma](https://www.kde.org/plasma-desktop) which looks gorgeous and does support HiDPI. Still on MacBook's screen GNOME was a bit more consistent: I've got too small icons here and there in Plasma. [LXQT](https://lxqt.github.io/) is another DE I'm interested in. Given the progress towards HiDPI support or possibility of getting an external monitor with ordinary resolution I'll probably be able to reevaluate my choice of desktop environment soon enough.

### Installation

Installation of GNOME was quite an easy task: I went for "minimal" `gnome-shell` package which is around 750 MB of dependencies in total (instead of around 1500 MB for `gnome` and 2030 MB for `gnome-extra`). As I was going to use [Wayland](https://wiki.archlinux.org/index.php/Wayland), I had to get [XWayland](https://wayland.freedesktop.org/xserver.html) separately: `xorg-server-xwayland` package wasn't pulled in as a dependency that led to `gnome-shell[600]: Failed to spawn Xwayland: Failed to execute child process "/usr/bin/Xwayland" (No such file or directory)` when starting GNOME.

### Startup

Because I still do some stuff in the text console, I have created a tiny script to easily start GNOME under Wayland manually as described on [ArchWiki](https://wiki.archlinux.org/index.php/GNOME#Wayland_sessions). I've tried to use [GDM](https://wiki.archlinux.org/index.php/GDM) first but it's not really needed in my setup. E.g. it doesn't make sense to type both disk encryption password and user's password to boot and if I'm not going to select different users/sessions why have a display manager in the first place? When starting GNOME I see couple of error messages `Activated service 'org.freedesktop.systemd1' failed: Process org.freedesktop.systemd1 exited with status 1` that doesn't seem to be critical, you can find a related discussion on [GitHub](https://github.com/systemd/systemd/issues/5247).

### Workman layout

I can't do much on a computer without a Workman keyboard layout. Fortunately it was installed already as part of `xkeyboard-config`, pulled in by GNOME. The only thing I had to do it to remap Caps Lock to Control which means editing `workman` section in `/usr/share/X11/xkb/symbols/us` and replacing `key <CAPS>` mapping with `{ [ Control_L ] };` (there's probably a better way to _override_ the keymap configuration instead to prevent the modification from being erased by an upgrade of the package).

### Disable cursor blinking

As you might already know from the previous part of the guide I don't particularly enjoy cursor flickering. Fortunately it is possible to disable it system-wide for GUI applications in GNOME: `gsettings set org.gnome.desktop.interface cursor-blink true`.

### More GNOME apps

After getting GNOME working I've installed `gnome-controll-center` which gives access to graphical preferences. The package asks you to select on of `libx264` and `libx264-10bit` dependencies, see [the Reddit post](https://www.reddit.com/r/archlinux/comments/30khba/libx264_vs_libx26410bit/) why you probably want non 10bit version. To be able to change desktop backgrounds I've also grabbed `gnome-backgrounds` package.

For a graphical file manager I've installed `nautilus` - the default one in GNOME, plus `sushi` which gives a preview of a selected file when hitting space, a shortcut I used to have from macOS. Some other GNOME packages I have installed: `gnome-documents` - to read books (e.g. EPUB); `gnome-calculator` - gives ability to use GNOME Overview search as calculator as well; `gnome-dictionary` - to look up definitions, analogue of macOS built-in dictionary; `gnome-keyring` - system-wide secret storage; `gnome-screenshot` - a really great tool for taking screenshots; `tracker` - to search for files from the Overview; `gnome-clocks` and `gnome-weather` - to get multiple clocks and a forecast in the calendar drop-down respectively; `gnome-maps` - a pretty good OpenStreetMap based application; `gnome-tweak-tool` - to have access to more detailed graphical configuration.

### Extensions

`gnome-shell-extensions` is a bundle of default GNOME extensions from which I use WindowsNavigator to switch between windows in Overview using a keyboard. See [the ArchWiki](https://wiki.archlinux.org/index.php/Gnome#Extensions) on details how to enable extension management using <https://extensions.gnome.org/>.

### Hide unwanted desktop icons

To get rid of icons of applications installed as dependencies that you don't use add `NoDisplay=True` in .desktop file. Copy the desktop file to `~/.local/share/applications` to not have it overwritten by every application update.

### Not a perfect story

One thing I don't like about GNOME so much is that it's very monolithic (I'm not sure if described below are the problems of GNOME itself or the Arch packages specifically though). It expects you to install full suite of applications along with Gnome Shell itself (given number of error messages in logs related to not found [D-Bus](https://wiki.archlinux.org/index.php/D-Bus) services for GNOME applications I've opted to not install. On one hand if you install only the shell you'll end up with non functional GUI elements (desktop background selection, settings button), on the other hand if you install `gnome-controll-center` Cheese webcam application gets pulled in (which is fine as I use it to test my webcam before calls but annoying nevertheless).

## Terminal emulator

[Tilix](https://gnunn1.github.io/tilix-web/) is a more future reach alternative to GNOME Terminal and a quite close rival to macOS' iTerm. It's quite young project, there's no Tilix package in the official repositories yet. The AUR package works well, except you'll have to recompile Tilix when its dependency `gtkd` is updated otherwise it will fail to launch. I've enabled "Run command as a login shell" in Tilix profile configuration configuration (section Command) to enable shell integration (like opening new tabs in the same working directory).

Not tied to specific terminal emulator, but to make shell more pleasant to use I've installed `bash-completion`.

## Building packages

When you install AUR packages or rebuild official packages from source `xz` utility is used to get smaller package size at expense of build time. Compression step takes a significant portion of build time and by using multiple threads as described [here](https://wiki.archlinux.org/index.php/Makepkg#Utilizing_multiple_cores_on_compression) you can reduce that time significantly. The same way you can speed up compilation of packages by [using multiple threads](https://wiki.archlinux.org/index.php/Makepkg#Parallel_compilation).

You can also build (slightly) faster binaries when compiling from source by sacrificing portability which doesn't matter if you run built packages only on your own machine. To use the instruction set of your specific CPU by add `-mnative` to the compiler flags (`CFLAGS` and `CXXFLAGS` in `/etc/makepkg.conf`). See [ArchWiki](https://wiki.archlinux.org/index.php/Makepkg#Building_optimized_binaries) for more information about package optimization.

## Browser

Not much to say here really. Firefox works great on Linux and with the recent improvements to speed and stability in versions 55-57 I've got no reasons to look elsewhere.

## Webcam

There's [an ongoing effort](https://github.com/patjak/bcwc_pcie) to provide a Linux driver for the FaceTime camera. To get it working just get `bcwc-pcie-git` from AUR. To test the lighting before video calls `cheese` program from GNOME works well.

## Graphics drivers

Fortunately I have only an integrated Intel GPU which has very good Linux support. Following [the ArchWiki article](https://wiki.archlinux.org/index.php/Intel_graphics#Installation) I've installed `xf86-video-intel` to get 2D hardware acceleration and `vulkan-intel` to have [Vulkan API](https://wiki.archlinux.org/index.php/Vulkan) support; mesa for 3D acceleration was pulled in by GNOME already. There're two [APIs for video hardware acceleration](https://wiki.archlinux.org/index.php/Hardware_video_acceleration) on Linux: VA-API and VDPAU developed by Intel and Nvidia respectively. To enable VA-API I've installed `libva-intel-driver` and to verify that it's indeed available `vainfo` from `libva-utils` (from AUR). I didn't get VDPAU to work under Wayland (even though it worked out of the box under Xorg). This is not critical in my case since my video player of choice [mpv](#video-player) supports VA-API. To avoid screen flickering multiple times during the boot I've enabled early loading of i915 kernel module (Intel graphics) as described [here](https://wiki.archlinux.org/index.php/Kernel_mode_setting#Early_KMS_start). The downside is the high brightness during early boot until disk password is entered.

## Touchpad

At first I've tried `xf86-input-mtrack` touchpad driver to get the beloved 3 finger drag gesture that I used to on macOS so much. But the driver is Xorg only meaning I won't be able to keep it moving to Wayland. I've did some research and basically the gesture is not coming to Wayland anytime soon (see [my Reddit post](https://www.reddit.com/r/archlinux/comments/6c64jr/3_finger_drag_for_wayland/)). After some frustration I've gave up on the idea, decided to unlearn the gesture and stuck with Wayland.

The only tweaking I did in the result was to enable tap to click, increase touchpad speed and enable natural scrolling via GNOME Settings.

## Text editor

I've replaced vim with gVim (one of the reasons being vim is compiled without +clipboard, meaning no clipboard access). Of course command line vim binary is included in the package as well. Because gVim's icon looks ugly on high resolution displays I've replaced it with the one from [VimR project](http://vimr.org). To do it change `Icon` value in gVim's .desktop file to the path to the new image (copy desktop file first to prevent overwrites as mentioned [above](#gnome)).

## Video player

I've settled on using [mpv](https://mpv.io/) which is very simple and powerful at the same time and has a nice command line interface. To enable hardware acceleration (which reduces CPU use significantly) two lines with `hwdec=vaapi` (use VA-API supported by my Intel GPU) and `opengl-backend=wayland` (make driver detection work properly under Wayland) in `~/.config/mpv/mpv.conf` is all I needed to do.

## Power saving

Even though I probably didn't get to 100% of the battery life I had with macOS I've came pretty close without spending too much time on it. First I've installed [`powertop`](https://wiki.archlinux.org/index.php/Powertop) which gives an interactive overview of power usage on a system and also allows to apply predefined set of rules to save energy. As described by the wiki I've created a systemd service to automatically apply powertop's suggestions on system startup. [TLP](https://wiki.archlinux.org/index.php/TLP) is another tool to save some battery life, see the installation section of the page on what systemd services it needs to have enabled/disabled. During experiments with power saving my Wi-Fi card got [hardware blocked](https://wiki.archlinux.org/index.php/Wireless_network_configuration#Rfkill_caveat) once which wasn't easy to troubleshoot as the MacBook have no indicator for the switch but was simple to fix with `rfkill` utility. Following the [ArchWiki power saving recommendations for my MacBook](https://wiki.archlinux.org/index.php/MacBookPro11,x#Powersave) I've disabled card reader as it was showing up in powertop and I don't use the device.

## Conclusions

It's been a long time (almost a year since the first post!) and an exciting journey, I have learned a lot. I'm not looking back at all really. While in the beginning it was overwhelming to learn so much stuff at once now I feel as much productive as on macOS (if not more). Not having to deal with App Store, iTunes, million ways to update installed programs and slow macOS updates is great.

Hope the series were useful to you. If you have any feedback, please [send it to me](/contact).
