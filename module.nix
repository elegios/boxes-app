{config, pkgs, lib, ...}:

let
  cfg = config.services.boxes-app;
  inherit (lib) mkEnableOption mkOption mkDefault mkPackageOption;
  inherit (lib.types) str port bool;
in
{
  options.services.boxes-app = {
    enable = mkEnableOption "A simple app for keeping track of box content";

    user = mkOption {
      type = str;
      default = "boxes-app";
      description = "User account under which boxes-app runs.";
    };

    group = mkOption {
      type = str;
      default = "boxes-app";
      description = "Group under which boxes-app runs.";
    };

    stateDir = mkOption {
      type = str;
      default = "/var/lib/boxes-app";
      description = "State and configuration directory Komga will use.";
    };

    backend = mkPackageOption pkgs "boxes-app" {};
    frontend = mkPackageOption pkgs "boxes-app-frontend" {};

    settings = {
      port = mkOption {
        type = port;
        description = "The port that boxes-app will listen on.";
        default = 8080;
      };
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
      description = "Whether to open the firewall for the port in {option}`services.boxes-app.settings.port`.";
    };
  };
  config = let inherit (lib) mkIf getExe; in mkIf cfg.enable {
    nixpkgs.overlays = [ (import ./overlay.nix) ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.port ];

    users.groups = mkIf (cfg.group == "boxes-app") { boxes-app = { }; };

    users.users = mkIf (cfg.user == "boxes-app") {
      boxes-app = {
        group = cfg.group;
        home = cfg.stateDir;
        description = "Boxes-app Daemon user";
        isSystemUser = true;
      };
    };

    systemd.tmpfiles.settings."10-boxes-app" = {
      "${cfg.stateDir}".d = {
        inherit (cfg) user group;
      };
    };

    systemd.services.boxes-app = {
      description = "Box management app.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      preStart = ''
        if [[ ! -e "${cfg.stateDir}/data.json" ]]; then
          echo '{"clock": 0, "state": {"spaces": {}}}' > "${cfg.stateDir}/data.json"
        fi
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${getExe cfg.backend} -s ${cfg.frontend}/lib/node_modules/boxes-app/dist -d '${cfg.stateDir}/data.json' -p ${toString cfg.settings.port}";

        StateDirectory = mkIf (cfg.stateDir == "/var/lib/boxes-app") "boxes-app";

        RemoveIPC = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        SystemCallFilter = [ "@system-service" ];
        ProtectSystem = "full";
        PrivateTmp = true;
        ProtectProc = "invisible";
        ProtectClock = true;
        ProcSubset = "pid";
        PrivateUsers = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        LockPersonality = true;
        RestrictNamespaces = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        SystemCallArchitectures = "native";
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
      };
    };
  };
}
