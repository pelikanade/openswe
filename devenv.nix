{
  pkgs,
  config,
  inputs,
  ...
}:
let
  openSwe = inputs.infrastructure.packages.${pkgs.stdenv.hostPlatform.system}.open-swe;
in
{
  packages = [
    openSwe
    pkgs.just
    pkgs.gh
    pkgs.git
    pkgs.curl
    pkgs.secretspec
  ];

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "";
    initialDatabases = [ { name = "openswe"; } ];
  };

  env = {
    PGDATABASE = "openswe";
    POSTGRES_URI = "postgresql:///openswe?host=${config.env.PGHOST}&port=${toString config.env.PGPORT}";
    LANGGRAPH_URL = "http://127.0.0.1:2024";
    LANGGRAPH_CLI_NO_ANALYTICS = "1";
  };

  processes.open-swe = {
    cwd = config.devenv.root;
    after = [ "devenv:processes:postgres" ];
    exec = ''
      set -euo pipefail
      # Reuse the signed-in GitHub identity unless an allowlist was supplied.
      if [[ -z "''${ALLOWED_GITHUB_USERS:-}" && -z "''${ALLOWED_GITHUB_ORGS:-}" ]]; then
        ALLOWED_GITHUB_USERS="$(gh api user --jq .login)"
        export ALLOWED_GITHUB_USERS
      fi
      exec secretspec run --provider keyring --profile default -- \
        open-swe --host 127.0.0.1 --port 2024
    '';
    ready.http.get = {
      host = "127.0.0.1";
      port = 2024;
      path = "/health";
    };
  };
}
