#!/usr/bin/env bash
#
# install.sh — bootstrap freedo758/Nix-Config from the NixOS installer
# environment, either as a brand-new host alongside the existing
# bootywarrior/leo config, or by renaming bootywarrior/leo in place to
# names of your choosing.
#
# Two modes:
#
#   RENAME MODE (--rename, or answer "yes" when asked)
#     Renames the existing hosts/bootywarrior -> hosts/<hostname>, and
#     replaces every whole-word occurrence of "bootywarrior" and "leo"
#     across the repo's text files with your chosen names. This also
#     fixes flake/outputs.nix automatically, since it just contains the
#     string "bootywarrior" like everything else. You'll be shown every
#     file that will change before anything is written.
#
#   ADD-HOST MODE (--no-rename, default if you decline the prompt)
#     Leaves bootywarrior/leo untouched and scaffolds a new
#     hosts/<hostname>/ next to it (mirrors the README's "Adding a new
#     host" section). Prints a flake/outputs.nix snippet for you to
#     paste in by hand, since blindly sed-editing Nix syntax next to
#     an existing entry is a good way to break it.
#
# Usage:
#   sudo ./install.sh
#   sudo ./install.sh -n mylaptop -t America/New_York -s 26.05 -u alex --rename
#   sudo ./install.sh -n secondbox -t America/New_York -s 26.05 --no-rename --no-desktop
#
set -euo pipefail

REPO_URL="https://github.com/freedo758/Nix-Config.git"
TARGET_ROOT="/mnt"
NIXOS_DIR="${TARGET_ROOT}/etc/nixos"

OLD_HOST="bootywarrior"
OLD_USER="leo"

HOSTNAME=""
TIMEZONE=""
STATE_VERSION=""
USERNAME="$OLD_USER"
INCLUDE_DESKTOP=1
RUN_INSTALL=1
RENAME_MODE=""   # "" = ask interactively, 1 = force rename, 0 = force add-host

usage() {
  cat <<EOF
Usage: sudo $0 [options]

  -n, --hostname NAME       Hostname for this machine (required, or you'll be prompted)
  -t, --timezone TZ         e.g. America/New_York (required, or you'll be prompted)
  -s, --state-version VER   NixOS state version, e.g. 26.05 (required, or you'll be prompted)
  -u, --user NAME           Username to use (default: leo)
      --rename              Rename bootywarrior/leo in place to your new names
      --no-rename           Keep bootywarrior/leo, add a new host alongside it
      --no-desktop          Skip modules/desktop (Hyprland/Steam) — use for headless hosts
      --no-install          Do everything except running 'nixos-install'
  -h, --help                Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--hostname) HOSTNAME="$2"; shift 2 ;;
    -t|--timezone) TIMEZONE="$2"; shift 2 ;;
    -s|--state-version) STATE_VERSION="$2"; shift 2 ;;
    -u|--user) USERNAME="$2"; shift 2 ;;
    --rename) RENAME_MODE=1; shift ;;
    --no-rename) RENAME_MODE=0; shift ;;
    --no-desktop) INCLUDE_DESKTOP=0; shift ;;
    --no-install) RUN_INSTALL=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "This must be run as root (you're installing to ${TARGET_ROOT})." >&2
  exit 1
fi

if ! mountpoint -q "$TARGET_ROOT" 2>/dev/null; then
  echo "Warning: ${TARGET_ROOT} doesn't look like a mountpoint." >&2
  read -rp "Continue anyway? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

# ---- Gather info -----------------------------------------------------------

if [[ -z "$HOSTNAME" ]]; then
  read -rp "Hostname for this machine: " HOSTNAME
fi
[[ -n "$HOSTNAME" ]] || { echo "Hostname is required."; exit 1; }

if [[ -z "$TIMEZONE" ]]; then
  read -rp "Timezone (e.g. America/New_York): " TIMEZONE
fi
[[ -n "$TIMEZONE" ]] || { echo "Timezone is required."; exit 1; }

if [[ -z "$STATE_VERSION" ]]; then
  read -rp "NixOS state version to use (e.g. 26.05): " STATE_VERSION
fi
[[ -n "$STATE_VERSION" ]] || { echo "State version is required."; exit 1; }

if [[ -z "$RENAME_MODE" ]]; then
  echo
  echo "This config is currently built around host '${OLD_HOST}' and user '${OLD_USER}'."
  read -rp "Rename them to '${HOSTNAME}' / user of your choice, in place? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    RENAME_MODE=1
  else
    RENAME_MODE=0
  fi
fi

if [[ $RENAME_MODE -eq 1 && "$USERNAME" == "$OLD_USER" ]]; then
  read -rp "New username (Enter to keep '${OLD_USER}'): " ans
  [[ -n "$ans" ]] && USERNAME="$ans"
fi

echo
echo "== Summary =="
echo "  mode:          $([[ $RENAME_MODE -eq 1 ]] && echo "rename ${OLD_HOST}/${OLD_USER} in place" || echo "add new host alongside ${OLD_HOST}")"
echo "  hostname:      $HOSTNAME"
echo "  timezone:      $TIMEZONE"
echo "  stateVersion:  $STATE_VERSION"
echo "  user:          $USERNAME"
echo "  desktop stack: $([[ $INCLUDE_DESKTOP -eq 1 ]] && echo yes || echo no)"
echo "  run install:   $([[ $RUN_INSTALL -eq 1 ]] && echo yes || echo no)"
echo
read -rp "Proceed? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || exit 1

# ---- 1. Clone / reuse the config -------------------------------------------

if [[ -d "$NIXOS_DIR/.git" ]]; then
  echo "==> ${NIXOS_DIR} already looks like a git checkout, reusing it."
else
  echo "==> Cloning ${REPO_URL} to ${NIXOS_DIR}"
  mkdir -p "$(dirname "$NIXOS_DIR")"
  git clone "$REPO_URL" "$NIXOS_DIR"
fi
cd "$NIXOS_DIR"

if [[ ! -d "hosts/${OLD_HOST}" ]]; then
  echo "Error: hosts/${OLD_HOST} not found — did the repo layout change?" >&2
  echo "You'll need to adjust this script or follow the README manually." >&2
  exit 1
fi

# ---- 2. Rename bootywarrior/leo throughout the repo, if requested ----------

rename_string_everywhere() {
  local old="$1" new="$2" desc="$3"
  if [[ "$old" == "$new" ]]; then
    return
  fi
  echo "==> Renaming $desc: '${old}' -> '${new}'"
  local files
  files=$(grep -rlI --exclude-dir=.git --exclude-dir=Wallpapers -w "$old" . 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "    (no occurrences found)"
    return
  fi
  echo "    Files that will change:"
  echo "$files" | sed 's/^/      /'
  while IFS= read -r f; do
    sed -i "s/\b${old}\b/${new}/g" "$f"
  done <<< "$files"
}

if [[ $RENAME_MODE -eq 1 ]]; then
  if [[ -d "hosts/${HOSTNAME}" && "${HOSTNAME}" != "${OLD_HOST}" ]]; then
    echo "Error: hosts/${HOSTNAME} already exists — pick a different name." >&2
    exit 1
  fi

  if [[ "${HOSTNAME}" != "${OLD_HOST}" ]]; then
    echo "==> hosts/${OLD_HOST} -> hosts/${HOSTNAME}"
    if [[ -d .git ]]; then
      git mv "hosts/${OLD_HOST}" "hosts/${HOSTNAME}"
    else
      mv "hosts/${OLD_HOST}" "hosts/${HOSTNAME}"
    fi
  fi

  echo
  echo "About to scan the repo for '${OLD_HOST}' and '${OLD_USER}' and replace them."
  echo "This includes flake/outputs.nix, modules/system/users.nix,"
  echo "modules/home-manager.nix, fish abbreviations, and anything under home/."
  read -rp "Show the list of affected files and proceed? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted before making changes."; exit 1; }

  rename_string_everywhere "$OLD_HOST" "$HOSTNAME" "hostname"
  rename_string_everywhere "$OLD_USER" "$USERNAME" "username"

  echo
  echo "NOTE: home/development/git.nix may also hardcode ${OLD_USER}'s actual"
  echo "Git name/email (not just the username string). Check it and update"
  echo "those manually if so — this script only renames identifiers, not"
  echo "personal details it can't guess."
  echo

  HOST_DIR="hosts/${HOSTNAME}"
else
  if [[ -d "hosts/${HOSTNAME}" ]]; then
    echo "Error: hosts/${HOSTNAME} already exists. Pick a different name or remove it first." >&2
    exit 1
  fi
  HOST_DIR="hosts/${HOSTNAME}"
fi

# ---- 3. Hardware scan -------------------------------------------------------

echo "==> Generating hardware configuration for this machine"
nixos-generate-config --root "$TARGET_ROOT"

GENERATED_HW="${TARGET_ROOT}/etc/nixos/hardware-configuration.nix"
if [[ ! -f "$GENERATED_HW" ]]; then
  echo "Error: expected ${GENERATED_HW} but it wasn't created." >&2
  exit 1
fi

mkdir -p "$HOST_DIR"
mv "$GENERATED_HW" "${HOST_DIR}/hardware-configuration.nix"

# ---- 4. variables.nix -------------------------------------------------------

if [[ $RENAME_MODE -eq 1 && -f "${HOST_DIR}/variables.nix" ]]; then
  # File already exists (renamed from bootywarrior) — update the fields that
  # differ per-machine rather than clobbering anything else in it.
  sed -i "s|time\.timeZone = \"[^\"]*\";|time.timeZone = \"${TIMEZONE}\";|" "${HOST_DIR}/variables.nix"
  sed -i "s|system\.stateVersion = \"[^\"]*\";|system.stateVersion = \"${STATE_VERSION}\";|" "${HOST_DIR}/variables.nix"
  echo "==> Updated ${HOST_DIR}/variables.nix (timezone, stateVersion)"
  echo "    Review it for hardware-specific bits (e.g. GPU env vars) that"
  echo "    may not apply to this machine."
else
  cat > "${HOST_DIR}/variables.nix" <<EOF
{ ... }:

{
  networking.hostName = "${HOSTNAME}";
  time.timeZone = "${TIMEZONE}";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "${STATE_VERSION}";
}
EOF
  echo "==> Wrote ${HOST_DIR}/variables.nix"
fi

# ---- 5. default.nix (add-host mode only needs to copy it) ------------------

if [[ $RENAME_MODE -eq 0 ]]; then
  cp "hosts/${OLD_HOST}/default.nix" "${HOST_DIR}/default.nix"
  echo
  echo "NOTE: ${HOST_DIR}/default.nix was copied verbatim from"
  echo "hosts/${OLD_HOST}/default.nix. Open it and remove anything genuinely"
  echo "${OLD_HOST}-specific (the README calls out an overlay workaround for"
  echo "dms-shell's calendar feature as one example)."
  echo

  if [[ "$USERNAME" != "$OLD_USER" ]]; then
    echo "NOTE: you asked for user '${USERNAME}', but this config's home/ tree"
    echo "and modules/home-manager.nix are currently written for '${OLD_USER}'."
    echo "Per the README's 'Adding a new user' section you'll want to either:"
    echo "  - duplicate home/ into home-${USERNAME}/ and trim it down, or"
    echo "  - add users.users.${USERNAME} in modules/system/users.nix and wire"
    echo "    home-manager.users.${USERNAME} in modules/home-manager.nix"
    echo "before rebuilding. This script won't guess at that for you."
    echo
  fi
fi

# ---- 6. flake/outputs.nix ----------------------------------------------------

if [[ $RENAME_MODE -eq 1 ]]; then
  if grep -q "nixosConfigurations\.${HOSTNAME}" flake/outputs.nix 2>/dev/null; then
    echo "==> flake/outputs.nix already refers to nixosConfigurations.${HOSTNAME} (renamed automatically)."
  else
    echo "Warning: nixosConfigurations.${HOSTNAME} not found in flake/outputs.nix." >&2
    echo "Open it and check the rename applied correctly before installing." >&2
    read -rp "Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
  fi
else
  MODULES_LIST="../modules/system"
  if [[ $INCLUDE_DESKTOP -eq 1 ]]; then
    MODULES_LIST="../modules/system
      ../modules/desktop"
  fi

  SNIPPET=$(cat <<EOF

nixosConfigurations.${HOSTNAME} = nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };

  modules = [
    ../hosts/${HOSTNAME}

    ${MODULES_LIST}
    ../modules/home-manager.nix
  ];
};
EOF
  )

  echo "$SNIPPET" > "${HOST_DIR}/flake-entry-snippet.nix.txt"

  echo "=============================================================="
  echo " MANUAL STEP REQUIRED"
  echo "=============================================================="
  echo "Open flake/outputs.nix and add this block next to the existing"
  echo "${OLD_HOST} entry (also saved to ${HOST_DIR}/flake-entry-snippet.nix.txt):"
  echo
  echo "$SNIPPET"
  echo "=============================================================="
  echo
  read -rp "Press Enter once you've added it (or Ctrl+C to stop here): " _

  if ! grep -q "nixosConfigurations\.${HOSTNAME}" flake/outputs.nix 2>/dev/null; then
    echo "Warning: I don't see nixosConfigurations.${HOSTNAME} in flake/outputs.nix yet." >&2
    echo "The install below will fail until that's added." >&2
    read -rp "Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
  fi
fi

# ---- 7. Install --------------------------------------------------------------

if [[ $RUN_INSTALL -eq 1 ]]; then
  echo "==> Running nixos-install --root ${TARGET_ROOT} --flake ${NIXOS_DIR}#${HOSTNAME}"
  nixos-install --root "$TARGET_ROOT" --flake "${NIXOS_DIR}#${HOSTNAME}"
  echo
  echo "==> Done. Reboot, log in as ${USERNAME}, and set a password with 'passwd' if needed."
else
  echo "==> Skipping nixos-install (--no-install was passed)."
  echo "When ready, run:"
  echo "  nixos-install --root ${TARGET_ROOT} --flake ${NIXOS_DIR}#${HOSTNAME}"
fi
