# Roku player: tracks, quality, skipping and Up Next (1 November 2026)

## What changed

The Roku player now has what the other Arc players have while watching (arc-roku#2):

- **The * button** opens a side panel: Audio, Subtitles, Quality, and Version and Chapters when the
  title has them. Back goes from a section to the list, then to the video.
- **Subtitles** are drawn by the app from Arc's WebVTT (`/items/{id}/subtitles/{track}/vtt`), as the
  LG/Samsung app does, in the profile's size, colour, background and position. The first track is
  chosen the way the other apps choose it (the profile's language and subtitle mode, else a forced
  track in the audio's language), and a picked language is saved to the profile. Picture
  subtitles (PGS, VobSub) aren't offered, as on the TV app.
- **Audio tracks** and **versions** restart the stream at the same point with the new choice; a
  picked audio language is saved to the profile. **Quality** limits match the web player's.
- **Skip Intro / Recap / Credits** appear from Arc's markers; OK skips. With the profile's "skip
  intros automatically" each intro is skipped once.
- **Up Next:** for episodes (when auto play is on), a card with the next episode counts down from
  10 when the credits start and at the end; OK plays it now, Back keeps watching.
- Every Roku plays H.264, so it is now always listed in the caps (the simulator, and possibly
  some models, answer CanDecodeVideo with nothing, which made Arc refuse to play at all).
- Movies show their year under the title in the player, not the title twice.

## Decisions

- Subtitles drawn by the app rather than Roku's own captions: Roku's player can't send the sign-in
  with a subtitle request, and drawing them keeps the profile's look the same as the other apps.
- Up Next uses `GET /items/{id}/next`; Arc's play queues aren't used by the Roku app yet.
- Speed choice is left out: Roku's Video node doesn't offer playback speed on most models.

## Logging

`Arc: subtitles loaded, N cues` and `Arc: playing the next episode`, in addition to the playback
attempt lines. No URLs, tokens or subtitle text.

## Checked, and what still needs a Roku

Unit tests cover language matching, the subtitle choice, WebVTT parsing and cue lookup, skip
markers, quality choices and version names. In the simulator against a test Arc: the options
panel and each section (audio, subtitles with a sidecar .srt, quality, chapters), subtitles drawn
over the video, and Up Next counting down and starting the next episode in place of the player.
Not checked on a real Roku: any of it with real video playing, subtitle timing during playback,
and the subtitle font (the simulator doesn't render system font files).
