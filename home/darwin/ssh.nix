# SSH client on the Mac. Keys live in 1Password (Settings → Developer →
# "Use the SSH agent"), so every connection is approved with Touch ID.
# University servers: bari is the jump host, hessen the dev machine
# (Nix environment there: home/hessen.nix).

let
  # Public half of the 1Password key "SSH Key" (uni servers + Gerrit). With
  # IdentitiesOnly, ssh asks the agent for just this key instead of offering
  # every 1Password key; several refused offers trip bari's
  # "Too many authentication failures" and a temporary block.
  zbhKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINevAV1Fz2FujIzF4F9V/WQ2Fobf/8cHDyTqjucY0suh";
in
{
  home.file.".ssh/zbh.pub".text = zbhKey + "\n";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # OpenSSH directive names, written as-is to ~/.ssh/config.
    settings = {
      "*" = {
        IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };

      bari = {
        HostName = "bari.zbh.uni-hamburg.de";
        Port = 7373;
        User = "mrueve";
        IdentityFile = "~/.ssh/zbh.pub";
        IdentitiesOnly = true;
      };

      # The short name is resolved by bari. ForwardAgent so git on hessen can
      # push to Gerrit with the 1Password key (no private key on the server).
      hessen = {
        HostName = "hessen";
        User = "mrueve";
        ProxyJump = "bari";
        ForwardAgent = true;
        IdentityFile = "~/.ssh/zbh.pub";
        IdentitiesOnly = true;
      };
    };
  };
}
