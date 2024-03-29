# gentoo-installer

Currently sets up a systemd/Gentoo install on LUKS with btrfs.

## Gentoo Installation
```
links gentoo.org/downloads
./check.sh

links wiki.gentoo.org/wiki/Handbook

./install.sh
```

### Kernel Checklist
* ALSA
* Btrfs
* CPU
* dm-crypt
* Ethernet
* GPU
* Vendor-specific
* iwd
* systemd
* Wifi
* Zstd

### Preinstallation

[Downloads](https://www.gentoo.org/downloads/)

```
sha512 -c install-amd64-*.iso.DIGESTS
gpg --auto-key-retrieve --keyserver hkps://keys.gentoo.org --verify install-amd64-*.iso.asc
```
Then
```
dd bs=4M if=/path/to/gentoo.iso of=/dev/sdX status=progress
```
or alternatively: [Ventoy](https://github.com/ventoy/Ventoy).

### GNU Screen
`screen`      New screen session

`screen -d`   Detaches another running session or shows sessions
`screen -dr`  Start and detach elsewhere (demonstrates importance of password)
`screen -dR`  Start and detach elsewhere or make new

Keyboard Shortcut | Screen Action
-|-
C-a S | Horizontal split
C-a \| | Vertical split
C-a TAB | Switch focus
C-a c | Open new terminal in new window
C-a " | Show available processes
C-a X | Kill window, not process
C-a :password | Set password for session
C-a C-x | Lock screen
C-a C-d | Detach to background
C-a \ | Kill all windows, terminate screen
C-a C-[ | Enter copy mode. Use SPACE to begin and end selection.
C-a C-] | Write the paste buffer to stdin

### Links
`links gentoo.org`

Key | Behavior
-|-
F1 | Help
ESC ESC | Menus
[  ] | Scroll left, right
p  l | Scroll up, down
