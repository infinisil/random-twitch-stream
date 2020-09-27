# Random Twitch Stream

A script to play random twitch streams for a given game and language, unbiased towards viewer count!

## Usage

To use the Twitch API, you need to create a Twitch Application on https://dev.twitch.tv/console/apps/create and put the client credentials in `./personal.nix` as such:

```nix
{
  id = "<your application client ID>";
  secret = "<your application secret>";
}
```

Then build it:
```bash
$ nix-build
```

And run it:
```bash
$ result/bin/random-twitch-stream
What game [empty for any game]? minecraft
What language (ISO 639-1 code)? ja
Game minecraft (27471), language ja
Getting streams for minecraft in ja
Finished fetching streams
[cli][info] Found matching plugin twitch for URL https://twitch.tv/777bigangel777
[cli][info] Available streams: audio_only, 1080p60 (worst, best)
[cli][info] Opening stream: 1080p60 (hls)
[plugin.twitch][info] Will skip ad segments
[cli][info] Starting player: mpv
```

## How it works

- Creates and caches a Twitch OAuth token with https://dev.twitch.tv/docs/authentication/getting-tokens-oauth#oauth-client-credentials-flow. This is necessary to access the API
- The game ID of the entered name is looked up using https://dev.twitch.tv/docs/api/reference#get-games. If the game couldn't be found, let the user retry
- Fetches all user IDs that are currently streaming for the entered game and language using https://dev.twitch.tv/docs/api/reference#get-streams. If the API limit is reached, it waits for a bit to retry
- All user IDs are shuffled, then sequentially processed:
  - First the user ID is converted to their stream URL using https://dev.twitch.tv/docs/api/reference#get-users
  - Then the stream is played using [Streamlink](https://github.com/streamlink/streamlink) and [mpv](https://github.com/mpv-player/mpv)
