# Public README and simulator screenshots

- Matched the other public Arc app READMEs, retained the sideload and build instructions, and added a guided brs-engine screenshot walk.
- Home and title pages keep the text title visible until the logo image loads. Missing artwork can no longer leave the title blank.
- Decisions: capture the built channel at its native simulator resolution. Use the shared server screenshot library with generated clips and separate test profiles.
- Checks: `npm run build`, `npm run check` and `npm test` passed. The first unit-test launch was blocked by sandbox network-interface enumeration and passed on retry outside that sandbox.
- Logging: unchanged. The screenshot helper reports filenames.
- [README screenshots](../screenshots/) are full-size 1920×1080 JPEGs. The guided helper also saved and converted a frame in a separate smoke check.
- Limits: brs-engine simulator only. Real Roku rendering and playback were not checked. The shared screenshot server used TMDB for metadata and artwork, including episode stills. The TVDB artwork host remained unavailable in the capture environment.
