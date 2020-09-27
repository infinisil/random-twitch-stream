let
  # Fetching from unstable to always have an up-to-date streamlink/mpv
  pkgs = import (fetchTarball channel:nixpkgs-unstable) {
    config = {};
    overlays = [];
  };

  personalError = ''
    To use the Twitch API, you need to create a Twitch Application on https://dev.twitch.tv/console/apps/create and put the client credentials in ${toString ./personal.nix} as such:

      {
        id = "<your application client ID>";
        secret = "<your application secret>";
      }
  '';

  personal =
    if builtins.pathExists ./personal.nix
    then import ./personal.nix
    else throw personalError;

  clientId = personal.id or (throw "id missing\n\n${personalError}");
  clientSecret = personal.secret or (throw "secret missing\n\n${personalError}");

  runtimeDeps = with pkgs; [
    coreutils
    gnugrep
    curl
    jq
    streamlink
    mpv
  ];

  script = pkgs.runCommandNoCC "random-twitch-stream" {
    nativeBuildInputs = [ pkgs.makeWrapper ];

    # For nix-shell
    buildInputs = runtimeDeps;
    CLIENT_ID = clientId;
    CLIENT_SECRET = clientSecret;
  } ''
    mkdir -p $out/bin
    cp ${./random-twitch-stream} $out/bin/random-twitch-stream
    patchShebangs $out/bin
    wrapProgram $out/bin/random-twitch-stream \
      --set PATH ${pkgs.lib.makeBinPath runtimeDeps} \
      --set CLIENT_ID $CLIENT_ID \
      --set CLIENT_SECRET $CLIENT_SECRET
  '';

in script
