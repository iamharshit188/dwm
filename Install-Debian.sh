#!/usr/bin/env bash
#
# Install-Debian.sh — set up dwm/dmenu/st/dwmblocks (this repo's suckless
# stack) plus its runtime companions on Debian 13 "trixie", using apt.
#
# This is the Debian counterpart to Install.sh (which is Arch/pacman-only).
# It builds dwm, dmenu, st and dwmblocks from the source trees in this repo,
# installs everything else (slock, picom, fonts, status-bar tooling, pywal,
# TLP, ...) from apt, and wires the repo's dotfiles/config snippets into
# place. It is safe to re-run: apt installs are naturally idempotent, and
# anything this script copies onto an existing file is backed up first.
#
set -euo pipefail
IFS=$'\n\t'

# --------------------------------------------------------------------------
# Globals
# --------------------------------------------------------------------------

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly repo_dir

SUDO_KEEPALIVE_PID=""

# apt package groups (see README/task notes for why each group exists).
readonly BUILD_PACKAGES=(
	build-essential git curl wget ca-certificates pkg-config
	libx11-dev libxft-dev libxinerama-dev libxrandr-dev libimlib2-dev
	fontconfig
	pciutils # gives us lspci, needed by NvidiaDetector.sh
)
readonly XSESSION_PACKAGES=(xorg xinit x11-xserver-utils)
# Runtime companions dwm/dmenu/st/dwmblocks need — NOT the suckless programs
# themselves, those are built from source below and must never be apt-installed.
readonly WM_RUNTIME_PACKAGES=(slock picom feh flameshot)
readonly FONT_PACKAGES=(fonts-jetbrains-mono fonts-noto)
readonly STATUSBAR_PACKAGES=(
	lm-sensors pamixer pipewire pipewire-pulse wireplumber
	network-manager htop bmon calcurse numlockx
)
readonly NOTIFY_PACKAGES=(libnotify-bin dunst)
readonly MEDIA_PACKAGES=(mpv yt-dlp sxiv jq)
readonly MISC_PACKAGES=(
	imagemagick trash-cli python3 python3-pip openssh-client
	tlp tlp-rdw powertop
)

# --------------------------------------------------------------------------
# Logging / prompting helpers
# --------------------------------------------------------------------------

info() { printf '[*] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }
err()  { printf '[x] %s\n' "$*" >&2; }

# confirm PROMPT — y/N prompt, defaults to "no".
confirm() {
	local prompt="$1" reply
	read -r -p "$prompt [y/N] " reply
	case "$reply" in
		[yY][eE][sS]|[yY]) return 0 ;;
		*) return 1 ;;
	esac
}

# --------------------------------------------------------------------------
# Preflight
# --------------------------------------------------------------------------

require_not_root() {
	if [ "${EUID}" -eq 0 ]; then
		err "Do not run this script as root/with sudo directly."
		err "Run it as your normal user (with sudo available); it will call sudo itself when it needs to."
		exit 1
	fi
}

check_os() {
	if command -v apt-get >/dev/null 2>&1; then
		:
	elif command -v apt >/dev/null 2>&1; then
		:
	else
		err "Neither apt-get nor apt was found on this system."
		err "This script only supports Debian (and close derivatives). For Arch Linux, use ./Install.sh instead."
		exit 1
	fi

	if [ ! -r /etc/os-release ]; then
		warn "Cannot read /etc/os-release; skipping distro/version check."
		return
	fi

	local os_id os_codename
	# shellcheck disable=SC1091 # /etc/os-release only exists at runtime, not at lint time
	os_id="$(. /etc/os-release && printf '%s' "${ID:-}")"
	# shellcheck disable=SC1091
	os_codename="$(. /etc/os-release && printf '%s' "${VERSION_CODENAME:-}")"

	if [ "$os_id" != "debian" ]; then
		warn "This does not look like Debian (ID=${os_id:-unknown}). Continuing anyway — many Debian derivatives work fine, but you're on your own if something doesn't."
	elif [ "$os_codename" != "trixie" ]; then
		warn "This is Debian '${os_codename:-unknown}', not 'trixie'. Continuing anyway; most of this script should still work on nearby releases."
	else
		info "Detected Debian trixie."
	fi
}

start_sudo_keepalive() {
	info "Checking sudo access (you may be prompted for your password)..."
	if ! sudo -v; then
		err "This script needs passwordless-after-prompt sudo access to install packages and system files."
		exit 1
	fi
	(
		while true; do
			sleep 60
			kill -0 "$$" 2>/dev/null || exit
			sudo -n true 2>/dev/null || true
		done
	) &
	SUDO_KEEPALIVE_PID=$!
}

stop_sudo_keepalive() {
	if [ -n "$SUDO_KEEPALIVE_PID" ]; then
		kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
	fi
}
trap stop_sudo_keepalive EXIT

# --------------------------------------------------------------------------
# File install helper (tier 2: confirm + timestamped backup on real conflict)
# --------------------------------------------------------------------------

# install_config_file SRC DEST USE_SUDO DESCRIPTION
# - DEST missing            -> copy straight over, no prompt.
# - DEST exists and matches -> no-op (idempotent re-run).
# - DEST exists and differs -> confirm(), back up with a timestamp, then copy.
install_config_file() {
	local src="$1" dest="$2" use_sudo="$3" desc="$4"
	local -a cp_cmd=(cp)
	[ "$use_sudo" = "true" ] && cp_cmd=(sudo cp)

	if [ ! -e "$dest" ]; then
		info "Installing $desc -> $dest"
		"${cp_cmd[@]}" "$src" "$dest"
		return 0
	fi

	if cmp -s "$src" "$dest" 2>/dev/null; then
		info "$desc already up to date at $dest"
		return 0
	fi

	if confirm "$dest already exists and differs from this repo's version. Overwrite $desc (existing file will be backed up first)?"; then
		local ts
		ts="$(date +%Y%m%d%H%M%S)"
		"${cp_cmd[@]}" "$dest" "$dest.bak.$ts"
		info "Backed up existing $dest -> $dest.bak.$ts"
		"${cp_cmd[@]}" "$src" "$dest"
		info "Installed $desc -> $dest"
	else
		warn "Skipped $desc; left existing $dest untouched."
	fi
}

# --------------------------------------------------------------------------
# apt: sources, update, package install
# --------------------------------------------------------------------------

apt_update() {
	info "Refreshing apt package lists..."
	sudo apt-get update
}

install_packages() {
	local -a all_packages=(
		"${BUILD_PACKAGES[@]}"
		"${XSESSION_PACKAGES[@]}"
		"${WM_RUNTIME_PACKAGES[@]}"
		"${FONT_PACKAGES[@]}"
		"${STATUSBAR_PACKAGES[@]}"
		"${NOTIFY_PACKAGES[@]}"
		"${MEDIA_PACKAGES[@]}"
		"${MISC_PACKAGES[@]}"
	)
	info "Installing ${#all_packages[@]} apt packages..."
	sudo apt-get install -y "${all_packages[@]}"
}

install_pywal() {
	# No pywal/python3-pywal apt package exists on Debian, and Scripts/wal +
	# Scripts/status.py `import pywal` via the plain system python3 (they are
	# NOT run through a venv), so pipx is the wrong tool here (it would
	# isolate pywal where that interpreter can't see it). trixie's system
	# python3 is externally-managed (PEP 668), so plain pip refuses to run
	# without --break-system-packages.
	info "Installing pywal for your user (python3 -m pip --user --break-system-packages)..."
	python3 -m pip install --user --break-system-packages pywal
}

# add_components_deb822 FILE — ensure every "Components:" line in a DEB822
# sources file (trixie's default /etc/apt/sources.list.d/debian.sources)
# includes contrib, non-free and non-free-firmware.
add_components_deb822() {
	local file="$1" tmp
	tmp="$(mktemp)"
	awk '
		BEGIN { needed[1]="contrib"; needed[2]="non-free"; needed[3]="non-free-firmware" }
		/^Components:/ {
			line = $0
			for (i = 1; i <= 3; i++) {
				c = needed[i]
				if (line !~ ("(^|[ \t])" c "([ \t]|$)")) line = line " " c
			}
			print line
			next
		}
		{ print }
	' "$file" > "$tmp"
	sudo install -m 0644 -o root -g root "$tmp" "$file"
	rm -f "$tmp"
	info "Updated Components: lines in $file"
}

# add_components_classic FILE — same, for the old one-line-per-source format
# (/etc/apt/sources.list), appending missing components to each active
# deb/deb-src line.
add_components_classic() {
	local file="$1" tmp
	tmp="$(mktemp)"
	awk '
		BEGIN { needed[1]="contrib"; needed[2]="non-free"; needed[3]="non-free-firmware" }
		/^[[:space:]]*deb(-src)?[[:space:]]/ {
			line = $0
			for (i = 1; i <= 3; i++) {
				c = needed[i]
				if (line !~ ("(^|[ \t])" c "([ \t]|$)")) line = line " " c
			}
			print line
			next
		}
		{ print }
	' "$file" > "$tmp"
	sudo install -m 0644 -o root -g root "$tmp" "$file"
	rm -f "$tmp"
	info "Updated deb/deb-src lines in $file"
}

# enable_nonfree_components — gated by confirm(); needed for
# firmware-misc-nonfree / nvidia-driver to be installable at all.
enable_nonfree_components() {
	local deb822_file="/etc/apt/sources.list.d/debian.sources"
	local classic_file="/etc/apt/sources.list"
	local target mode

	if [ -f "$deb822_file" ]; then
		target="$deb822_file"; mode="deb822"
	elif [ -f "$classic_file" ]; then
		target="$classic_file"; mode="classic"
	else
		warn "Could not find $deb822_file or $classic_file; skipping apt component setup."
		warn "Add contrib/non-free/non-free-firmware to your apt sources manually if you need them."
		return 1
	fi

	if grep -q "non-free-firmware" "$target" 2>/dev/null && grep -q "contrib" "$target" 2>/dev/null; then
		info "contrib/non-free/non-free-firmware already enabled in $target"
		return 0
	fi

	echo "Installing firmware-misc-nonfree / nvidia-driver requires the contrib,"
	echo "non-free and non-free-firmware apt components, which are not enabled"
	echo "by default on trixie. This will edit: $target"
	if ! confirm "Enable contrib/non-free/non-free-firmware now (a timestamped backup will be made first)?"; then
		warn "Leaving apt sources untouched; nvidia-driver install will likely fail without this."
		return 1
	fi

	local ts
	ts="$(date +%Y%m%d%H%M%S)"
	sudo cp "$target" "$target.bak.$ts"
	info "Backed up $target -> $target.bak.$ts"

	if [ "$mode" = "deb822" ]; then
		add_components_deb822 "$target"
	else
		add_components_classic "$target"
	fi

	apt_update
	return 0
}

# --------------------------------------------------------------------------
# NVIDIA detection / optional proprietary driver install
# --------------------------------------------------------------------------

handle_nvidia() {
	info "Checking for an NVIDIA GPU (via NvidiaDetector.sh)..."
	local nvidia_output
	nvidia_output="$(bash "$repo_dir/NvidiaDetector.sh" 2>&1 || true)"
	printf '%s\n' "$nvidia_output"

	if ! printf '%s\n' "$nvidia_output" | grep -q "^NVIDIA cards detected:"; then
		info "No NVIDIA card detected; skipping proprietary driver setup."
		return 0
	fi

	warn "An NVIDIA GPU was detected."
	echo "This script can install Debian's proprietary driver (nvidia-driver)"
	echo "plus firmware-misc-nonfree. This pulls in non-free apt components"
	echo "(see below) and requires a reboot afterwards to take effect."
	if confirm "Install the proprietary NVIDIA driver now?"; then
		if enable_nonfree_components; then
			info "Installing nvidia-driver and firmware-misc-nonfree..."
			if sudo apt-get install -y nvidia-driver firmware-misc-nonfree; then
				info "NVIDIA driver installed. Reboot before it takes effect."
			else
				err "nvidia-driver install failed. Confirm contrib/non-free/non-free-firmware are enabled and re-run, or install it manually."
			fi
		else
			warn "Skipping nvidia-driver install since apt components aren't enabled."
		fi
	else
		info "Skipping proprietary NVIDIA driver install; the open-source nouveau driver will be used instead."
	fi
}

# --------------------------------------------------------------------------
# Build dwm / st / dmenu / dwmblocks from source
# --------------------------------------------------------------------------

build_component() {
	local name="$1" dir="$2"
	info "Building and installing $name from $dir..."
	if (cd "$dir" && sudo make clean install); then
		info "$name installed successfully."
	else
		err "$name failed to build/install. Check the make output above."
		return 1
	fi
}

build_suckless_programs() {
	build_component "dwm" "$repo_dir/dwm"
	build_component "st (simple terminal)" "$repo_dir/st"
	build_component "dmenu" "$repo_dir/dmenu"
	build_component "dwmblocks" "$repo_dir/dwmblocks"
}

# --------------------------------------------------------------------------
# Scripts -> ~/.local/bin (tier 1: silent per-file backup, no prompt — this
# is this installer's own managed script directory, re-running is expected
# to refresh it)
# --------------------------------------------------------------------------

install_user_scripts() {
	local dest_dir="$HOME/.local/bin"
	local src_dir="$repo_dir/Scripts"
	local f base dest ts count=0

	mkdir -p "$dest_dir" "$HOME/.local/src"
	info "Installing status-bar/utility scripts into $dest_dir..."

	for f in "$src_dir"/*; do
		[ -f "$f" ] || continue
		base="$(basename "$f")"
		dest="$dest_dir/$base"

		if [ -e "$dest" ] && ! cmp -s "$f" "$dest"; then
			ts="$(date +%Y%m%d%H%M%S)"
			cp -p "$dest" "$dest.bak.$ts"
			info "Backed up existing $dest -> $dest.bak.$ts"
		fi

		cp -p "$f" "$dest"
		chmod +x "$dest"
		count=$((count + 1))
	done
	info "Installed $count scripts to $dest_dir"
}

# --------------------------------------------------------------------------
# Dotfiles, fonts, TLP, touchpad config
# --------------------------------------------------------------------------

install_dotfiles() {
	info "Installing dotfiles into $HOME..."
	install_config_file "$repo_dir/.bashrc" "$HOME/.bashrc" false ".bashrc"
	install_config_file "$repo_dir/.xinitrc" "$HOME/.xinitrc" false ".xinitrc"
	# xinit execs this directly, so it must be executable regardless of
	# whether install_config_file just wrote it or left an existing one.
	chmod +x "$HOME/.xinitrc"
}

install_fonts() {
	local dest="/usr/local/share/fonts/dwm-nerd-fonts"
	info "Installing bundled Nerd Fonts to $dest..."
	sudo mkdir -p "$dest"
	sudo cp -f "$repo_dir"/Fonts/* "$dest/"
	info "Refreshing font cache..."
	sudo fc-cache -f >/dev/null
}

install_tlp_config() {
	install_config_file "$repo_dir/tlp.conf" /etc/tlp.conf true "TLP configuration"
}

enable_tlp() {
	info "Enabling and starting the TLP power-management service..."
	sudo systemctl enable --now tlp
}

install_touchpad_config() {
	sudo mkdir -p /etc/X11/xorg.conf.d
	install_config_file "$repo_dir/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf true "libinput touchpad config"
}

print_grub_note() {
	cat <<'EOF'

[*] Skipping GRUB configuration.
    This repo's `grub` file is written for Arch's grub-mkconfig workflow
    (GRUB_DISTRIBUTOR="Arch", etc.) and is wrong for Debian, so
    Install-Debian.sh never touches /etc/default/grub.
    CPU power limiting on battery is already handled by tlp.conf
    (CPU_MAX_PERF_ON_BAT=30 and friends), so GRUB kernel-parameter tuning
    isn't required for that. If you still want to hand-tune GRUB defaults,
    edit /etc/default/grub yourself and run `sudo update-grub` afterwards.
EOF
}

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------

print_summary() {
	cat <<EOF

============================================================
 dwm / st / dmenu / dwmblocks setup for Debian trixie is done.
============================================================

Installed:
  - dwm, st, dmenu, dwmblocks: built from source in this repo and installed
    system-wide (make clean install)
  - slock, picom, feh, flameshot, dunst and the rest of the apt package list
  - Scripts/* -> ~/.local/bin (dwmblocks status modules + utilities)
  - .bashrc, .xinitrc -> $HOME (any previous versions were backed up first)
  - Bundled Nerd Fonts -> /usr/local/share/fonts/dwm-nerd-fonts (fc-cache refreshed)
  - tlp.conf -> /etc/tlp.conf, tlp.service enabled and started
  - 30-touchpad.conf -> /etc/X11/xorg.conf.d/
  - pywal installed for your user account (python3 -m pip --user --break-system-packages)

Next steps:
  1. Run 'sudo sensors-detect' to configure lm-sensors (interactive — not run
     automatically by this script). The cpu and fan_speed.sh status modules
     need it to report real values.
  2. Log out of any existing graphical session, log in on a TTY, and run:
       startx
  3. If you enabled the proprietary NVIDIA driver above, reboot before it
     takes effect.
  4. GRUB was intentionally left untouched — see the note above.

Thanks for using these dots.
EOF
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

main() {
	require_not_root
	check_os
	info "Starting Debian trixie setup from $repo_dir"

	start_sudo_keepalive

	apt_update
	install_packages
	install_pywal

	build_suckless_programs
	handle_nvidia

	install_user_scripts
	install_dotfiles
	install_fonts
	install_tlp_config
	enable_tlp
	install_touchpad_config

	print_grub_note
	print_summary
}

main "$@"
