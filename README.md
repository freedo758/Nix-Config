# Perfected-NixOS
![imagealt](<img width="1920" height="1080" alt="2026-07-14-013228_hyprshot" src="https://github.com/user-attachments/assets/6131e15d-58a0-4600-9665-c2a3c4681497" />)


A flake-based NixOS + Home Manager configuration, currently built for one
host (`bootywarrior`) and one user (`leo`).

## Layout

```
.
├── flake.nix                # inputs only
├── flake/outputs.nix        # nixosConfigurations
├── hosts/<hostname>/        # per-machine: hardware scan, hostname, timezone, stateVersion
├── modules/system/          # NixOS: boot, hardware, networking, security, services, users
├── modules/desktop/         # NixOS: Hyprland enablement, Steam/GameMode
├── modules/home-manager.nix # wires Home Manager into the NixOS system
├── home/                    # everything Home Manager owns (packages, shell, dev tools,
│                             # desktop/theme config, session vars) for the user above
└── overlays/                # nixpkgs overlays
```

NixOS (`hosts/`, `modules/system`, `modules/desktop`) only handles boot,
hardware, networking, users, security, system services, and enabling
Hyprland/Steam. Everything else — packages, shell config, Git, theming,
Hyprland's own configuration, etc. — lives under `home/` and is managed by
Home Manager for the `leo` user.

## Installing on a new machine

1. Boot the NixOS installer and partition/mount disks as usual.

2. Generate a fresh hardware scan and grab the relevant bits:

   ```bash
   nixos-generate-config --root /mnt
   ```

   This writes `/mnt/etc/nixos/hardware-configuration.nix`. You'll drop
   your own version of this file into `hosts/<hostname>/` (see below) — do
   not hand-edit it, just let the generator produce it.

3. Clone this repo (or copy it) to `/mnt/etc/nixos`:

   ```bash
   git clone <https://github.com/freedo758/Nix-Config.git> /mnt/etc/nixos
   cd /mnt/etc/nixos
   ```

4. If you're installing onto the existing `bootywarrior` host, copy the
   freshly generated file over:

   ```bash
   cp /mnt/etc/nixos/hardware-configuration.nix hosts/bootywarrior/hardware-configuration.nix
   ```

   If this is a *new* machine, see "Adding a new host" below instead.

5. Install:

   ```bash
   nixos-install --root /mnt --flake /mnt/etc/nixos#bootywarrior
   ```

6. Reboot, log in as `leo`, and set a password if you haven't already
   (`passwd`).

## Applying changes on an already-installed machine

From `/etc/nixos` (or wherever this repo lives):

```bash
sudo nixos-rebuild switch --flake .#bootywarrior
```

The `fish` shell shipped by this config already has abbreviations for the
common commands (see `home/shell/fish.nix`):

| Abbreviation | Does |
|---|---|
| `nrs`   | `sudo nixos-rebuild switch` |
| `nrsf`  | `sudo nixos-rebuild switch --flake /etc/nixos#bootywarrior` |
| `flakeup` | `sudo nix flake update` |
| `ngarbage` | `sudo nix-collect-garbage --delete-older-than 7d` |
| `ncon`  | `cd /etc/nixos` |

## Adding a new host

Each host gets its own directory under `hosts/`, containing a real
hardware scan, host-specific settings, and an entry point that pulls both
together:

1. Create the directory and generate hardware config for the new machine:

   ```bash
   mkdir hosts/<new-hostname>
   nixos-generate-config --show-hardware-config > hosts/<new-hostname>/hardware-configuration.nix
   ```

2. Create `hosts/<new-hostname>/variables.nix`, based on
   `hosts/bootywarrior/variables.nix`, with that machine's own hostname,
   timezone, and any hardware-specific `environment.variables` (e.g. GPU
   driver env vars — `RUSTICL_ENABLE` is AMD-specific and may not apply):

   ```nix
   { ... }:

   {
     networking.hostName = "<new-hostname>";
     time.timeZone = "America/New_York";
     i18n.defaultLocale = "en_US.UTF-8";
     system.stateVersion = "26.05"; # keep this matching whatever release you first installed with
   }
   ```

3. Create `hosts/<new-hostname>/default.nix` (copy
   `hosts/bootywarrior/default.nix` as a starting point — it already
   imports `./hardware-configuration.nix` and `./variables.nix`, and
   pulls in the same overlay/nix-settings that every host wants). Trim or
   adjust anything that's genuinely `bootywarrior`-specific, like the
   click-threading overlay workaround if you don't use `dms-shell`'s
   calendar feature on the new box.

4. Add a new entry to `flake/outputs.nix`, next to `bootywarrior`:

   ```nix
   nixosConfigurations.<new-hostname> = nixpkgs.lib.nixosSystem {
     inherit system;
     specialArgs = { inherit inputs; };

     modules = [
       ../hosts/<new-hostname>

       ../modules/system
       ../modules/desktop
       ../modules/home-manager.nix
     ];
   };
   ```

   If the new host shouldn't get the desktop/Hyprland/gaming stack (e.g.
   it's a headless server), drop `../modules/desktop` from that list.

5. Build/install it the same way as `bootywarrior`, substituting the new
   hostname in the `--flake` target.

## Adding a new user

There are two levels to a user: the **NixOS account** (login, shell,
groups) and their **Home Manager profile** (packages, dotfiles, shell
config, theming). Both currently live under a single user, `leo`.

1. **NixOS account** — add the new user in `modules/system/users.nix`,
   alongside the existing `leo` block:

   ```nix
   { pkgs, ... }:

   {
     programs.fish.enable = true;

     users.users.leo = {
       isNormalUser = true;
       description = "leo";
       extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
       shell = pkgs.fish;
     };

     users.users.<newuser> = {
       isNormalUser = true;
       description = "<newuser>";
       extraGroups = [ "networkmanager" "video" "audio" "input" ]; # drop "wheel" unless they need sudo
       shell = pkgs.fish;
     };
   }
   ```

   This module is shared across every host that imports `modules/system`,
   so the new user will exist on all of them unless you scope it into a
   specific host's `default.nix` instead.

2. **Home Manager profile** — everything under `home/` is currently
   written for a single user and wired up in `modules/home-manager.nix`
   via `home-manager.users.leo = import ../home/default.nix;`. To give
   the new user their own profile:

   - Duplicate `home/` to a new top-level directory (e.g. `home-<newuser>/`)
     and trim it down to whatever that user actually wants — most of it
     (`packages/gaming.nix`, `theme/matugen.nix`, etc.) is very
     `leo`-specific and probably shouldn't be copied wholesale.
   - Update `home/default.nix` (or the new copy) with that user's own
     `home.username` / `home.homeDirectory`.
   - In `modules/home-manager.nix`, add:

     ```nix
     home-manager.users.<newuser> = import ../home-<newuser>/default.nix;
     ```

   If the new user just wants a near-identical setup to `leo` (unlikely,
   since things like `home/development/git.nix` hardcode `leo`'s Git
   identity), it's simpler to just point both usernames at the same
   `home/default.nix` — but you'll still want to fix the Git
   `user.name`/`user.email` per person.

3. Rebuild:

   ```bash
   sudo nixos-rebuild switch --flake .#bootywarrior
   ```

   Then set a password for the new account: `sudo passwd <newuser>`.
