{
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # Enables PAM for hyprlock so it can authenticate against the user's
  # login password.
  security.pam.services.hyprlock = { };
}
