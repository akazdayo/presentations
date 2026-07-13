{
  self,
  system,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    3000
  ];
  systemd.services.go-server = {
    wantedBy = ["multi-user.target"];
    script = ''
      # self.packages... で上のビルド結果を参照
      ${self.packages.${system}.default}/bin/lt-slides
    '';
  };
}
