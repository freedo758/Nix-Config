{ ... }:

{
  programs.git = {
    enable = true;
    settings.user.name = "Leo";
    settings.user.email = "bootywarrior@email.com";
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
