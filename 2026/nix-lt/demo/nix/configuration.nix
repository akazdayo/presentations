{modulesPath, ...}: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ./server.nix
  ];

  networking.hostName = "do-1";
  time.timeZone = "Asia/Tokyo";

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  system.stateVersion = "26.05";
}
