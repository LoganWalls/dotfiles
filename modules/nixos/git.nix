# Shared git setup for NixOS hosts.
#
# The settings themselves live in config/git/, which makoto reads directly
# through its ~/.config symlink. Including those files here keeps a single
# source of truth: edit config/git/config and every host picks it up (after a
# rebuild on NixOS). SSH keys are not managed here; each host uses its own.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    git-lfs # filter.lfs
    delta # core.pager, interactive.diffFilter
  ];

  environment.etc.gitconfig.text = ''
    [include]
    	path = ${../../config/git/config}
    [core]
    	excludesFile = ${../../config/git/ignore}
  '';
}
