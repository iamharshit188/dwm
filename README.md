# dwm — a suckless-based tiling WM setup

A dynamic tiling window manager desktop built on the [suckless](https://suckless.org) stack — **dwm**, **dmenu**, **st** — plus **dwmblocks** for the status bar, tied together with [pywal](https://github.com/dylanaraps/pywal) color theming and a set of shell-script status/utility modules.

## Screenshots

![Screenshot](https://github.com/iamharshit188/dwm/blob/master/1.png?raw=true)
<br>
![Screenshot](https://github.com/iamharshit188/dwm/blob/master/2.png?raw=true)
<br>
![Screenshot](https://github.com/iamharshit188/dwm/blob/master/3.png?raw=true)

## What's Included

- **[dwm](https://dwm.suckless.org)** — dynamic tiling window manager, built from source with a custom `dwm/config.h` and the [bar-padding patch](dwm/patch/dwm-barpadding-20211020-a786211.diff) applied on top of upstream.
- **[dmenu](https://tools.suckless.org/dmenu/)** — the suckless application launcher, built from source.
- **[st](https://st.suckless.org)** — the suckless simple terminal, built from source with the [scrollback patch](st/Patches/st-scrollback-0.8.5.diff) applied on top of upstream.
- **[dwmblocks](https://github.com/torrinfail/dwmblocks)** — a modular status-bar feeder for dwm, configured in `dwmblocks/config.h` to run the scripts below.
- **`Scripts/`** — the shell/Python scripts that feed dwmblocks (CPU, memory, battery, network, clock, fan speed) plus a handful of standalone utilities (wallpaper downloader, screenshot cleanup, music search, etc).
- **`Fonts/`** — the bundled IBM 3270 Nerd Font family (regular, condensed, semi-condensed × mono/proportional variants), installed system-wide so the bar's icon glyphs render.
- **`.walls/`** — a curated collection of 17 wallhaven wallpapers.
- Two installers: `Install.sh` for Arch Linux, `Install-Debian.sh` for Debian 13 "trixie".

## Requirements

- A Linux machine (laptop or desktop) that can run an X11 session.
- `sudo`/root access (both installers install system packages and write system config files).
- Currently targets **Arch Linux** (via `Install.sh` + pacman) and **Debian 13 "trixie"** (via `Install-Debian.sh` + apt). Other distros aren't supported out of the box.

## Installation

### Arch Linux

```sh
git clone https://github.com/iamharshit188/dwm --depth 1
cd dwm
./Install.sh
```

`Install.sh` (pacman-based):

- Refuses to run on a non-pacman system.
- Sets up the [chaotic-aur](https://aur.chaotic.cx/) repo (imports its signing key, installs the keyring/mirrorlist packages) and replaces `/etc/pacman.conf` with the one in this repo.
- Runs `NvidiaDetector.sh` to check for an NVIDIA GPU via `lspci` (non-fatal if none is found or drivers aren't installed yet).
- Installs dependencies and tools with `pacman`: `libx11 libxft imagemagick feh libxinerama xorg-server xorg-xinit ttf-jetbrains-mono noto-fonts python-pip trash-cli asusctl envycontrol google-chrome openssh libappindicator-gtk3 tlp powertop dunst libnotify`.
- Installs `pywal` for your user via `pip install --user --break-system-packages`.
- Builds and installs **dwm**, **st**, **dmenu**, **dwmblocks** from source (`make clean install` in each directory — this is what actually applies the patches, since the patched source is already checked into this repo).
- Backs up and replaces `/etc/default/grub` with this repo's `grub` file, then runs `grub-mkconfig`.
- Backs up and replaces `/etc/tlp.conf` with this repo's `tlp.conf`, then enables `tlp.service`.
- Copies `Fonts/` into `/usr/share/fonts/dwm-nerd-fonts` and refreshes the font cache.
- Copies `Scripts/*` into `~/.local/bin` and makes them executable.
- Backs up and copies `.bashrc` and `.xinitrc` into `$HOME`.
- Seeds `~/.config/wallpapers/wall1.jpg` from a wallpaper in `.walls/` if it doesn't already exist (so `status.py` has something to run `wal -i` against on first boot).
- Backs up and replaces `/etc/X11/xorg.conf.d/30-touchpad.conf` with this repo's `30-touchpad.conf`.
- Prints a final reminder to reboot, then run `startx` after logging into a tty.

### Debian 13 (trixie)

```sh
git clone https://github.com/iamharshit188/dwm --depth 1
cd dwm
./Install-Debian.sh
```

`Install-Debian.sh` (apt-based; safe to re-run):

- Refuses to run as root — run it as your normal user, it calls `sudo` itself when needed — and keeps sudo alive in the background while it works.
- Warns (but doesn't stop) if the OS isn't detected as Debian trixie specifically.
- `apt-get update`, then installs a curated package set covering build tools (`build-essential`, `libx11-dev`, `libxft-dev`, `libxinerama-dev`, `libxrandr-dev`, `libimlib2-dev`, `pciutils`, ...), the X session (`xorg`, `xinit`, `x11-xserver-utils`), WM runtime companions (`slock`, `picom`, `feh`, `flameshot`), fonts (`fonts-jetbrains-mono`, `fonts-noto`), status-bar tooling (`lm-sensors`, `pamixer`, `pipewire`/`pipewire-pulse`, `wireplumber`, `network-manager`, `htop`, `bmon`, `calcurse`, `numlockx`), notifications (`libnotify-bin`, `dunst`), media (`mpv`, `yt-dlp`, `sxiv`, `jq`), and misc tools (`imagemagick`, `trash-cli`, `python3-pip`, `openssh-client`, `tlp`, `tlp-rdw`, `powertop`).
- Installs `pywal` for your user via `python3 -m pip install --user --break-system-packages` (trixie's system Python is externally managed, so this flag is required).
- Builds and installs **dwm**, **st**, **dmenu**, **dwmblocks** from source (`make clean install`).
- Runs `NvidiaDetector.sh`; if an NVIDIA GPU is found, **asks for confirmation** before enabling the `contrib`/`non-free`/`non-free-firmware` apt components (backing up your sources file first) and installing `nvidia-driver` + `firmware-misc-nonfree`.
- Installs `Scripts/*` into `~/.local/bin`, backing up any existing same-named file that differs first.
- Installs `.bashrc` and `.xinitrc` into `$HOME` — for each, if the destination already exists and differs it asks before overwriting and makes a timestamped backup; `.xinitrc` is always left executable.
- Seeds `~/.config/wallpapers/wall1.jpg` from a wallpaper in `.walls/` if it doesn't already exist (so `status.py` has something to run `wal -i` against on first boot).
- Installs the bundled fonts to `/usr/local/share/fonts/dwm-nerd-fonts` and refreshes the font cache.
- Installs `tlp.conf` to `/etc/tlp.conf` and enables/starts `tlp.service`.
- Installs `30-touchpad.conf` to `/etc/X11/xorg.conf.d/`.
- **Deliberately skips GRUB configuration** — this repo's `grub` file is written for Arch's `grub-mkconfig` workflow and is wrong for Debian, so it's never touched. Battery CPU power limiting is instead handled by `tlp.conf` alone.

Manual follow-up it prints at the end:

1. Run `sudo sensors-detect` yourself (interactive — the `cpu` and `fan_speed.sh` status modules need it configured to report real values).
2. Log out of any existing graphical session, log into a TTY, and run `startx`.
3. If the NVIDIA driver was installed, reboot before it takes effect.
4. If you want GRUB-level CPU power-limit tuning, hand-edit `/etc/default/grub` and run `sudo update-grub` yourself.

## Post-Install / First Boot

- Log in on a TTY (not a display manager — neither installer sets one up) and run:
  ```sh
  startx
  ```
- `.xinitrc` needs to be executable. `Install-Debian.sh` guarantees this itself; if you installed via `Install.sh` or copied `.xinitrc` manually, run `chmod +x ~/.xinitrc` if `startx` fails.
- `.xinitrc` starts (in order): `dwmblocks`, `dunst` (notification daemon, for the `notify-send` calls in several status scripts), `picom` (compositor, for transparency), restores your last wallpaper via `~/.fehbg` if it exists, runs `wal -R` to reapply the last pywal colorscheme, runs `~/.local/bin/status.py`, then `exec dwm`.
- Both installers seed `~/.config/wallpapers/wall1.jpg` from a wallpaper in `.walls/` (if that file doesn't already exist), since `Scripts/status.py` hard-codes that path for its `wal -i` call and would otherwise fail on the very first `startx`. Both installers also install `dunst`, so `notify-send` calls have somewhere to go out of the box.
- `wal -R` still needs a previous pywal run to have populated `~/.cache/wal` — that only happens once `status.py` runs `wal -i` on first boot, so the very first `startx` after install is expected to set up your colorscheme, not restore one.

## Keybindings

Source of truth: [`dwm/config.h`](dwm/config.h). `MODKEY` is `Mod4Mask` — the **Super/Windows key**.

> **Some of these spawn scripts that aren't in this repo.** `fixscreen1`, `fixscreen`, `sndcpyshimt`, `delblur`, `addblur`, `scrcpyshit`, and `w3mterm` are commands the original author has on their own machine — there's no matching script anywhere under `Scripts/`. Either drop your own same-named scripts somewhere on `$PATH`, or remove/comment out those lines in `dwm/config.h` before `make install`, otherwise those bindings will just silently do nothing.

> **Duplicate bindings.** dwm's `keypress()` loop runs *every* matching entry in `keys[]`, it doesn't stop at the first (or take only the last) match. Two keys are bound twice in the current `config.h`:
> - `Super+A` — first bound to spawn `alacritty`, later in the array also bound to spawn `emacsclient -c`. Pressing it fires **both** spawns.
> - `Super+I` — first bound to spawn `delblur` (a personal script not in this repo, see above), later also bound to `setlayout` (switch to the tiled layout). Pressing it fires both.
>
> This is left as-is here since fixing it is outside the scope of this README — edit `dwm/config.h` yourself if you only want one effect per key.

### Applications

| Keybinding | Action |
|---|---|
| `Super + Return` | Open terminal (`st`) |
| `Super + D` | dmenu launcher (`dmenu_run`) |
| `Super + R` | rofi launcher (`rofi -show drun`) |
| `Super + E` | File manager (`thunar`) |
| `Super + V` | Audio mixer (`pavucontrol`) |
| `Super + M` | Screenshot GUI (`Scripts/flameshotgui`, wraps `flameshot gui`) |
| `Super + A` | Spawn `alacritty` **and** `emacsclient -c` (duplicate binding, see note above) |
| `Super + N` | `w3mterm` (not included, see note above) |
| `Super + 9` | `fixscreen1` (not included, see note above) |
| `Super + 8` | `fixscreen` (not included, see note above) |
| `Super + 7` | `sndcpyshimt` (not included, see note above) |
| `Super + U` | `addblur` (not included, see note above) |
| `Super + Y` | `scrcpyshit` (not included, see note above) |
| `Super + I` | `delblur` (not included) **and** set tiled layout (duplicate binding, see note above) |

### Window & Layout Management

| Keybinding | Action |
|---|---|
| `Super + J` / `Super + K` | Focus next / previous window in the stack |
| `Super + Q` | Kill the focused client |
| `Super + B` | Toggle the status bar |
| `Super + Space` | Cycle to the previous layout |
| `Super + Shift + Space` | Toggle floating for the focused window |
| `Super + H` / `Super + L` | Shrink / grow the master area (`mfact ∓0.05`) |
| `Super + [` / `Super + ]` | Decrease / increase number of clients in master area |
| `Super + Tab` | Re-select the last-viewed tag set |
| `Super + O` | Floating layout |
| `Super + P` | Monocle layout |

### Tags / Workspaces

`dwm/config.h` defines 7 tags, but only tags 1–6 have keybindings (`TAGKEYS` is only invoked for `XK_1`…`XK_6`) — the 7th tag has no bound key in the current config.

| Keybinding | Action |
|---|---|
| `Super + [1-6]` | View tag |
| `Super + Ctrl + [1-6]` | Toggle tag visibility |
| `Super + Shift + [1-6]` | Move focused window to tag |
| `Super + Ctrl + Shift + [1-6]` | Toggle tag on the focused window |
| `Super + 0` | View all tags |
| `Super + Shift + 0` | Tag the focused window with all tags |

### Monitors & Session

| Keybinding | Action |
|---|---|
| `Super + ,` / `Super + .` | Focus previous / next monitor |
| `Super + Shift + ,` / `Super + Shift + .` | Move focused window to previous / next monitor |
| `Super + Shift + Q` | Quit dwm |

### Mouse Bindings

| Click | Action |
|---|---|
| `Super + Button1` drag on a client | Move window |
| `Super + Button2` on a client | Toggle floating |
| `Super + Button3` drag on a client | Resize window |
| `Button2` on window title | Zoom focused window to/from master |
| `Button2` on status text | Spawn terminal (`st`) |
| `Button1` on tag bar | View tag |
| `Button3` on tag bar | Toggle view tag |
| `Super + Button1` on tag bar | Tag the focused window |
| `Super + Button3` on tag bar | Toggle tag on the focused window |

## Statusbar (dwmblocks)

`dwmblocks/config.h` runs these modules left-to-right, separated by ` | `:

| Order | Script | Interval | Signal | Shows |
|---|---|---|---|---|
| 1 | `fan_speed.sh` | 1s | – | CPU/GPU fan RPM from `sensors` (needs `sensors-detect` run once) |
| 2 | `cpu` | 5s | 4 | Core 0 temperature from `sensors`; click for top CPU processes, middle-click opens `htop` |
| 3 | `cpubars` | 1s | 16 | Per-core load as a small unicode bar graph; middle-click opens `htop` |
| 4 | `nettraf` | 1s | 16 | Network RX/TX bytes since last poll; click opens `bmon` |
| 5 | `memory` | 1s | 10 | Used/total RAM in GiB (`free`); click for top memory processes, middle-click opens `htop` |
| 6 | `battery` | 1s | 1 | Charge status + percentage per battery (warns below 25% while discharging); scroll to adjust `xbacklight` |
| 7 | `clock` | 5s | 4 | Date + clock-face emoji + time; left-click shows a 3-day appointment view (`calcurse -d3`) and the month (`cal`), middle-click opens `calcurse` |

Most modules also respond to right-click (button 3) with a `notify-send` explaining what the icons mean, and to button 6 by opening the script itself in `$EDITOR`.

Two other scripts exist in `Scripts/` but are **not** currently wired into `dwmblocks/config.h`'s module list — add a line to `blocks[]` if you want them on the bar:

- `internet` — wifi/ethernet/VPN status with signal strength.
- `volume` — current volume/mute status (`wpctl`); scroll to change, middle-click to mute, click opens `pulsemixer`.

Other utility scripts in `Scripts/` (installed to `~/.local/bin`, not part of the bar):

- `checkgpu` — prints the GPU line from `lspci`.
- `music` — plays a YouTube search result in `mpv` (`mpv ytdl://ytsearch:<query> --no-video`).
- `suspend` — locks the screen and suspends (`slock systemctl suspend`).
- `sscleanup` — deletes everything in `~/Pictures/Screenshots`.
- `status.py` — sets the root window color from the current pywal palette and configures a US/RU keyboard layout toggle; run from `.xinitrc` (see the first-run gotcha above).
- `wal` — a thin wrapper invoking `pywal`'s CLI entry point.
- `waldlp` — searches and downloads wallpapers from wallhaven.cc via `sxiv`; reads overrides from `~/.config/waldlrc` if present.

## Directory Structure

```
dwm/                Suckless dwm source + dwm/config.h (bar-padding patch applied)
dmenu/               Suckless dmenu source
st/                  Suckless st source + config.h (scrollback patch applied)
dwmblocks/           Statusbar feeder source + dwmblocks/config.h (module list)
Scripts/             Statusbar modules + utility scripts -> installed to ~/.local/bin
Fonts/               Bundled IBM 3270 Nerd Font family
.walls/              17 wallhaven wallpapers
.config/             starship.toml (shell prompt config, see Customization)
Install.sh           Arch Linux installer (pacman)
Install-Debian.sh    Debian 13 "trixie" installer (apt)
NvidiaDetector.sh    Shared NVIDIA GPU detection helper used by both installers
.bashrc              Installed to $HOME
.xinitrc             Installed to $HOME; starts dwmblocks, picom, wallpaper, pywal, dwm
30-touchpad.conf     libinput touchpad config -> /etc/X11/xorg.conf.d/ (Arch and Debian)
tlp.conf             TLP power management config -> /etc/tlp.conf (Arch and Debian)
grub                 Arch-only GRUB defaults -> /etc/default/grub (Install.sh only)
pacman.conf          Arch pacman config incl. chaotic-aur (Install.sh only)
1.png, 2.png, 3.png  Screenshots referenced above
```

## Customization

- **Keybindings and appearance** — `dwm/config.h`: fonts, colors, gaps, tags, layouts, and the `keys[]`/`buttons[]` arrays documented above. `dwm/config.h` also defines a couple of window rules (`rules[]`), e.g. Gimp opens floating. Rebuild with `sudo make clean install` inside `dwm/` after editing.
- **Statusbar modules** — `dwmblocks/config.h`: the `blocks[]` array controls which scripts run, in what order, on what interval, and which real-time signal updates them. Rebuild with `sudo make clean install` inside `dwmblocks/` after editing.
- **Shell prompt** — `.config/starship.toml` defines a [starship](https://starship.rs) prompt, and `.bashrc` will `eval "$(starship init bash)"` if `starship` is on `$PATH`. Neither installer installs `starship` itself or copies this file to `~/.config/` — install starship separately and copy `.config/starship.toml` to `~/.config/starship.toml` yourself if you want it.
- **Wallpaper downloader defaults** — `Scripts/waldlp` reads `~/.config/waldlrc` if it exists, letting you override its defaults (`walldir`, `cachedir`, `sxiv_otps`, `max_pages`, `sorting`, `quality`, `atleast`) without editing the script.

## Uninstalling / Rolling Back

Both installers back up any existing file they'd otherwise overwrite, as `<original-path>.bak.<unix-timestamp>`, before writing over it — for example `/etc/tlp.conf.bak.1730000000`, `~/.xinitrc.bak.1730000000`, `/etc/default/grub.bak.1730000000`, or `/etc/X11/xorg.conf.d/30-touchpad.conf.bak.<timestamp>`. To revert a change, find the matching `.bak.*` file next to the file that was replaced and copy it back into place. Fonts copied to `/usr/share/fonts/dwm-nerd-fonts` (Arch) or `/usr/local/share/fonts/dwm-nerd-fonts` (Debian), and scripts copied to `~/.local/bin`, are not automatically removed by any uninstall step — delete those directories/files by hand if you want them gone, and `sudo make uninstall` inside `dwm/`, `dmenu/`, `st/`, or `dwmblocks/` removes each corresponding suckless binary.

## Credits & Acknowledgements

This repo packages patched, pre-configured builds of the [suckless.org](https://suckless.org) tools, plus a third-party statusbar feeder:

- **[dwm](https://dwm.suckless.org)** — dynamic window manager, by the suckless.org community (see [`dwm/LICENSE`](dwm/LICENSE) for the full author list).
- **[dmenu](https://tools.suckless.org/dmenu/)** — dynamic menu, by the suckless.org community (see [`dmenu/LICENSE`](dmenu/LICENSE)).
- **[st](https://st.suckless.org)** — simple terminal, by the suckless.org community (see [`st/LICENSE`](st/LICENSE)).
- **[dwmblocks](https://github.com/torrinfail/dwmblocks)** — statusbar feeder for dwm, © 2020 torrinfail (see [`dwmblocks/LICENSE`](dwmblocks/LICENSE)).

All credit for the upstream window manager, menu, terminal, and statusbar-feeder design goes to those projects and their authors; this repo builds patched, configured versions of them.

## License

There is no top-level license file for this repository. The `dwm/`, `dmenu/`, `st/`, and `dwmblocks/` subdirectories retain their original upstream MIT/X11 (dwm, dmenu, st) and ISC (dwmblocks) licenses — see the `LICENSE` file inside each of those directories. The custom configuration, patches, and scripts elsewhere in this repo are provided as-is, with no license file currently specified.
