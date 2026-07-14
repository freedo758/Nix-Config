{ ... }:

{
  programs.git = {
    enable = true;
    settings.user.name = "Leo";
    settings.user.email = "alfredleofaus@gmail.com";
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
