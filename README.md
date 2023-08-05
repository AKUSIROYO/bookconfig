You know, there are these cheap ARM netbooks that can run GNU/Linux.
I have one with the WM8505 ... um, SoC?
So here's a repo for putting together other people's hard work into a vaguely bootable set of files, so that you can run Debian bookworm.
This only works for my exact model of netbook, so I think you'll need some tweaks to make it work.

The idea is that you'd run `make`, and it'll create `boot.zip` and `rootfs.tar.gz`.
You gotta make two partitions on an SD card and extract them and stuff.
TODO: Look up what the partitions ought to be and document them here.
Or maybe write a script that does it.

I build this on Debian unstable, and I have the following packages installed for this:
* make
* bc
* bison
* flex
* gcc
* libssl-dev
* gcc-arm-linux-gnueabi
* u-boot-tools
* zip
* fakeroot
* multistrap

## Catalog of everything in this repo

The `Makefile` describes the high level steps for doing everything.
And it has the various compilation options for the kernel.
And it has a list of packages to install in the root filesystem.

There's actually a whole 'nother branch, `kernel`, which is a blind rebase of [@linux-wmt's kernel](https://github.com/linux-wmt/linux-vtwm) onto later mainline kernel releases.
When you run `make`, it'll check out the kernel branch into a subdirectory.

Some kernel configuration options are in `seed`, which are mostly taken from [@linux-wmt's wiki](https://github.com/linux-wmt/linux-vtwm/wiki/Build-the-source).
Other options are arbitrary things that I've turned on as I needed, not in any principled way.

The uboot script is in `cmd`, which I've also taken from [@linux-wmt's wiki](https://github.com/linux-wmt/linux-vtwm/wiki/Boot-from-sd-card).
Supposedly, the exact black magic incantation needed here differs from model to model, so you might have to tweak this.

It builds the root filesystem with the `buildrootfs` script.

The root filesystem is set up with an init script `ship/sbin/init`.
When you first boot the root filesystem, this script configures the packages and also sets up a user.

## Uncategorized disclosures

It sets up the system so that there's a user with sudo access, and you can't log in as root.

It sets up the root filesystem with some network-related packages.
This includes the non-free `firmware-misc-nonfree` package.

It sets up an NTP client.

It sets the LCD contrast on boot.
Use `/etc/udev/rules.d/10-display.rules` to get it the way you like.

It has a systemd service `wlgpio` to control the internal USB WiFi adapter.
Use `systemctl start wlgpio` to power the adapter on / `systemctl stop wlgpio` to power the adapter off.

## Workflow for kernel branch

```
   upstream v1          upstream v2
  /                    /
-o-(mainline changes)-o
  \                    \
   (cherry-pick)        (cherry-pick) <- k2 (private)
    \                    \
-----o--------------------o <- kernel

```
The `kernel` branch is a merge commit whose second parent is the changes rebased on some upstream release, and whose first parent is the previous state of the branch.
That is, the latest rebase is at `kernel^2`, and the previous rebase is at `kernel~^2`, and so on.
At the end of following the merge commits' first parents, you'll reach a version of [@linux-wmt's `testing` branch](https://github.com/linux-wmt/linux-vtwm/commit/c4386efea112830fb82e33dfaf0fe712ee57f5a9) (they disclaim that they may rebase that branch).

1. Privately, move to a branch without these merge commits: `git checkout -b k42 kernel^2`
2. Fetch an upstream version to rebase onto: `git fetch --no-tags torvalds v4.2`
3. Do the rebase: `git rebase FETCH_HEAD`
4. Create a new commit to link the history: `git commit-tree -p refs/heads/kernel -p HEAD -m "rebase v4.2" HEAD^{tree}`
5. Move the `kernel` branch: `git update-ref refs/heads/kernel (whatever the previous step prints)`

(It's all weird like that to avoid back-and-forth checkouts.)
