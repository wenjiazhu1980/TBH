# Steam Audio Audit

Last reviewed: 2026-06-16

## Scope

This note records reproducible technical checks for the official Steam media currently exposed by the `TBH: Task Bar Hero` store page. It does not store official audio, derived clips, spectrogram images, or decoded audio in the repository.

Primary source:

- [Valve/Steam, 2026-06-16, Store page HTML for AppID 3678970: `https://store.steampowered.com/app/3678970/TBH_Task_Bar_Hero/`]
- [Valve/Steam, 2026-06-16, Steam appdetails API for AppID 3678970: `https://store.steampowered.com/api/appdetails?appids=3678970&filters=basic`]
- [Valve/Steam CDN, 2026-06-16, Trailer HLS manifest extracted from the Store page]

Source limitation: these are official Steam/Steam-CDN sources, but they are one source family, not independent confirmations. Confidence is High for the fetched stream metadata and measured technical audio statistics at the review time; confidence is Low for any per-event gameplay SFX inference because the trailer audio is not an isolated SFX source.

## Reproduction

Run:

```bash
scripts/audit-steam-audio.sh
```

Optional short sample:

```bash
AUDIT_SECONDS=15 scripts/audit-steam-audio.sh
```

Local packaged SFX audit:

```bash
scripts/audit-local-sfx.sh
```

Local runtime audio route self-test:

```bash
swift run --disable-sandbox TBH --self-test
```

The script:

- Fetches the official Steam page into a temporary directory.
- Extracts the current trailer `hlsManifest`.
- Uses `ffprobe` to print stream metadata.
- Uses `ffmpeg` filters `ebur128`, `volumedetect`, `astats`, and `silencedetect`.
- Checks embedded extras videos from the same page.
- Deletes the temporary page copy on exit and writes no official media asset into the repository.

The local SFX script:

- Derives the required event sound list from `GameAudioEvent` in `Sources/App/GameAudio.swift`.
- Confirms every `GameAudioEvent` case is routed by runtime code, every `BattleEvent` case is represented in `GameEngine.audioEvent(for:)`, and `GameLoop.handleBattleEvent` calls that shared mapping before playback.
- Checks expected battle-event routes: attack/support attack -> attack or critical SFX, skill/support skill -> skill-cast or critical SFX, damage -> damaged SFX, victory -> victory SFX, defeat -> defeat SFX.
- Verifies that each referenced WAV exists, that `sfx_manifest.tsv` maps every event to `generated_substitute` / `officialAudio=false` provenance, and that the manifest's format, duration, SHA-256 and byte counts match the actual WAV payloads. When `dist/TBH.app` exists, reruns the same audit against the packaged `Extracted/sfx/` directory and compares packaged WAV plus manifest payloads with source files.
- Reports duration, channel count, sample rate, bit depth, RMS dBFS, peak dBFS, onset time, zero-crossing rate, coarse spectral centroid, and high/low-frequency energy ratios for every packaged event sound.
- Fails on obvious technical outliers: non-mono files, non-22050 Hz sample rate, non-16-bit PCM, overlong/too-short event sounds, near-silent peaks, clipping-adjacent peaks, extreme RMS values, duplicate WAV payloads, weak envelope activity, or event-profile drift such as a critical hit losing its brighter/noisier profile, a skill cast losing its slower onset, or defeat no longer reading lower than victory.
- Parses `GameAudioEvent.minimumInterval`, verifies every event has a runtime throttle, checks repeatable combat, inventory/preview and terminal/progression events against separate interval ranges, and rejects terminal/progression cues that are throttled no longer than repeatable combat cues.
- Parses the runtime volume values from `GameAudioEvent.volume`, then renders three local sequence mixes (`combat_burst`, `reward_chain`, `defeat_chain`) so short event clusters are checked for peak headroom and RMS energy against the trailer baseline.

The local runtime self-test:

- Asserts the shared `GameEngine.audioEvent(for:)` mapping for every `BattleEvent` route, including crit and non-crit attack/skill variants.
- Asserts every `GameAudioEvent.minimumInterval` has a local playback-throttle profile, stays within its category range, and keeps terminal/progression cues throttled longer than repeatable combat cues.
- Drives the real DEBUG `GameEngine.runSelfTestTick()` path through a deterministic live victory, then verifies combat SFX, `battleWon`, reward settlement, play-time accumulation, progress advance, and automatic next-battle restart all occur through the same runtime chain.
- Uses an injected recording audio client to verify Settings preview, manual equip, Cube infusion, Alchemy, chest opening, Synthesis, offline level-up, sound mute, and sound re-enable behavior without playing real sound during the test run.

## Current Trailer Evidence

Extracted official HLS manifest:

```text
https://video.fastly.steamstatic.com/store_trailers/3678970/382795355/00fc4626d01ee9913ba6551f90fe26bec2b7bf73/1779737646/hls_264_master.m3u8?t=1779737804
```

`ffprobe` stream metadata:

```text
format: hls
duration: 47.000000s
audio: AAC LC, 48000 Hz, stereo, about 197647 bit/s
video variants: H.264 High at 1920x1080, 1280x720, 854x480, 640x360
frame rate: 30000/1001 fps
```

`ffmpeg` loudness and waveform measurements over the full 47s trailer audio:

```text
Integrated loudness: -15.3 LUFS
Loudness range: 4.6 LU
True peak: 0.0 dBFS
volumedetect mean_volume: -16.4 dB
volumedetect max_volume: 0.0 dB
astats overall RMS level: -16.402901 dB
astats overall peak level: 0.022399 dB
silencedetect noise=-45dB:d=0.2: no silence events detected
```

Interpretation:

- The official trailer is a continuous mastered promo mix, not isolated combat or UI event SFX.
- The mix is hot and near full scale, with no detected sustained silence under the checked threshold.
- It is useful as a broad loudness/energy reference for the macOS app's generated SFX, but it cannot prove exact original per-event attack, hit, loot, equip, victory, or defeat sounds.

## Embedded Extras Videos

The Steam page also exposes short embedded extras videos for wishlist, interface, battlescene, and cube visuals. The audit script probes those MP4/WebM URLs from the page. Current checks show those extras are video-only, so they are useful for visual animation review but not for direct audio-event fidelity.

## App Implications

Current macOS app state:

- Packaged WAV files under `Sources/Resources/Extracted/sfx/` are local generated substitutes, not official extracted audio. `sfx_manifest.tsv` records the required event mapping, `generated_substitute` provenance, `officialAudio=false` flag, format fields, duration, SHA-256 and byte count for every current cue.
- `GameAudio` prefers packaged SFX and falls back to macOS system sounds only when a resource is missing.
- `ResourceSelfTest` validates event coverage, rejects unreferenced bundled WAV files, rejects exact duplicate WAV payload reuse across different events, checks representative `BattleEvent` routes through `GameEngine.audioEvent(for:)`, checks playability, 16-bit PCM encoding, mono channel count, 22050 Hz sample rate, 0.05-0.75s SFX duration, RMS level and peak level, verifies every `GameAudioEvent.volume` against local runtime-volume categories, verifies every `GameAudioEvent.minimumInterval` against the same local throttle categories used by the shell audit and DEBUG self-test, and now also guards basic local substitute SFX relationships: critical hit longer than basic attack, skill cast longer than basic attack, level-up longer and at least as peaky as preview, and item-consumed at least as long and at least as peaky as item-equipped.
- `scripts/audit-local-sfx.sh` quantifies packaged event SFX against the same broad technical boundaries, statically audits runtime routing, and now applies event-profile checks for duration, envelope activity, onset, zero-crossing rate, coarse spectral centroid, high/low-frequency energy ratio, duplicate payloads, cross-event relationships, per-event runtime playback volume, runtime-volume sequence mixes, runtime playback throttles, generated-substitute manifest provenance, and packaged app WAV plus manifest payload parity when `dist/TBH.app` exists. Current local results cover all 11 `GameAudioEvent` sounds and all 7 `BattleEvent` routes, with 16-bit PCM mono 22050 Hz WAV files, duration range `0.110-0.360s`, RMS range `-22.7..-11.2 dBFS`, peak range `-11.1..-6.5 dBFS`, coarse spectral-centroid range `553..3173 Hz`, runtime-volume range `0.36-0.46`, and minimum-interval range `0.18-0.50s`. The current sequence mixes measure `combat_burst` at `0.790s`, `-21.5 dBFS` RMS and `-14.0 dBFS` peak; `reward_chain` at `1.640s`, `-23.6 dBFS` RMS and `-16.0 dBFS` peak; and `defeat_chain` at `0.530s`, `-22.6 dBFS` RMS and `-14.0 dBFS` peak. Current runtime volumes are `0.42` for repeatable combat events, `0.36` for loot/equip/item-consumed/preview UI events, and `0.46` for victory/defeat/level-up cues. Current runtime throttles are `0.18s` for repeatable combat events, `0.25s` for loot/equip/item-consumed/preview UI events, and `0.50s` for victory/defeat/level-up cues.
- `TBH --self-test` now also verifies the runtime event path with an injected audio client, including battle-event route mapping, local playback volume profiles, local minimum playback interval profiles, a real tick-driven battle victory and settlement path, preview/equip/chest/Synthesis/level-up event emission, mute suppression, and re-enable behavior.

Practical tuning boundary:

- Keep generated SFX short and non-looping for UI/gameplay events.
- Current local SFX sit below trailer true peak, avoid clipping, and have RMS values around the trailer's measured `-16.4 dB` broad energy reference, but this is only a technical substitute check.
- Current runtime-volume event clusters retain at least 14 dB of digital headroom in the deterministic sequence checks, so typical short bursts should not clip even though exact original mix behavior is still unknown.
- Current runtime throttles keep repeatable combat sounds responsive while spacing terminal/progression cues longer; this guards against obvious local spam regressions, not original event-cadence parity.
- Avoid claiming original audio parity until authorized assets or in-game captures provide isolated event sounds.
- Use the trailer baseline only to prevent obviously underpowered or overlong substitute sounds, not to reverse-engineer exact event audio.
