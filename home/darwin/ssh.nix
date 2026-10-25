# SSH client on the Mac. Keys live in 1Password (Settings → Developer →
# "Use the SSH agent"), so every connection is approved with Touch ID.
# University servers: bari is the jump host, hessen the dev machine
# (Nix environment there: home/hessen.nix).

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };

      bari = {
        hostname = "bari.zbh.uni-hamburg.de";
        port = 7373;
        user = "mrueve";
      };

      # The short name is resolved by bari. ForwardAgent so git on hessen can
      # push to Gerrit with the 1Password key (no private key on the server).
      hessen = {
        hostname = "hessen";
        user = "mrueve";
        proxyJump = "bari";
        forwardAgent = true;
      };
    };
  };
}
