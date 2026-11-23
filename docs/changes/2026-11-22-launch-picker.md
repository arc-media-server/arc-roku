# Who's watching on Roku

On a fresh channel launch, Arc asks who's watching when there is more than one
household profile. A single unlocked profile keeps its existing fast path.
Returning to an open channel keeps the current profile.

Settings can remember one unlocked profile on this Roku. A deleted profile or a
new PIN brings back the picker. Signing out clears the preference. Arc logs
launch decisions without names, IDs or credentials.

[Plex for Roku](https://support.plex.tv/articles/204275243-settings-plex-for-roku/)
can bypass a profile PIN with automatic sign-in. Arc requires the PIN each time.

The Roku simulator used a local stand-in server for both launch paths.
[Picker screenshot](2026-11-22-launch-picker/picker.jpg).
A focused Settings callback check covered replacing the saved profile, turning
the setting off and leaving it disabled for a PIN. The simulator drew the
Settings shell without the list. Physical Roku hardware was not tried.
