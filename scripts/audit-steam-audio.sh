#!/usr/bin/env bash
set -euo pipefail

app_url="${APP_URL:-https://store.steampowered.com/app/3678970/TBH_Task_Bar_Hero/}"
audit_seconds="${AUDIT_SECONDS:-0}"
tmpdir="$(mktemp -d)"
html_file="$tmpdir/steam-app.html"
extras_file="$tmpdir/extras.txt"

cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool curl
require_tool perl
require_tool ffprobe
require_tool ffmpeg

curl -L --compressed -A "Mozilla/5.0" -s "$app_url" > "$html_file"

hls_manifest="$(
  perl -0777 -ne '
    if (/hlsManifest&quot;:&quot;([^&]+)&quot;/) {
      $u = $1;
      $u =~ s#\\/#/#g;
      $u =~ s/&amp;/&/g;
      print $u;
    }
  ' "$html_file"
)"

if [[ -z "$hls_manifest" ]]; then
  echo "could not find hlsManifest in Steam page: $app_url" >&2
  exit 1
fi

perl -0777 -ne '
  $base = "";
  if (/data-store_page_asset_url="&quot;([^&]+)&quot;"/) {
    $base = $1;
    $base =~ s#\\/#/#g;
    $base =~ s/&amp;/&/g;
  }

  while (m{(https://shared\.(?:fastly|akamai)\.steamstatic\.com/store_item_assets/steam/apps/3678970/extras/[^" <]+?\.(?:mp4|webm)\?t=\d+)}g) {
    print "$1\n";
  }

  while (m{(https:\\/\\/shared\.(?:fastly|akamai)\.steamstatic\.com\\/store_item_assets\\/steam\\/apps\\/3678970\\/extras\\/[^"&]+?\.(?:mp4|webm)\?t=\d+)}g) {
    $u = $1;
    $u =~ s#\\/#/#g;
    print "$u\n";
  }

  while ($base ne "" && m{&quot;urlPart&quot;:&quot;(extras\\/[^&]+?\.(?:mp4|webm))&quot;}g) {
    $part = $1;
    $part =~ s#\\/#/#g;
    $u = $base;
    $u =~ s/%s/$part/;
    print "$u\n";
  }
' "$html_file" | sort -u > "$extras_file"

ffmpeg_audio() {
  local filter="$1"
  shift || true

  if [[ "$audit_seconds" != "0" ]]; then
    ffmpeg \
      -hide_banner \
      -nostdin \
      -v info \
      -i "$hls_manifest" \
      -map 0:a:0 \
      -t "$audit_seconds" \
      -vn \
      -af "$filter" \
      -f null - 2>&1
  else
    ffmpeg \
      -hide_banner \
      -nostdin \
      -v info \
      -i "$hls_manifest" \
      -map 0:a:0 \
      -vn \
      -af "$filter" \
      -f null - 2>&1
  fi
}

echo "Source page: $app_url"
echo "Trailer HLS: $hls_manifest"
echo

echo "== Trailer stream metadata =="
ffprobe \
  -v error \
  -show_entries stream=index,codec_type,codec_name,profile,sample_rate,channels,channel_layout,width,height,r_frame_rate,avg_frame_rate,bit_rate \
  -show_entries format=duration,format_name \
  -of json \
  "$hls_manifest"

echo
echo "== Trailer loudness summary =="
ffmpeg_audio "ebur128=peak=true" | awk '/Summary:/{capture=1} capture {print}'

echo
echo "== Trailer volume summary =="
ffmpeg_audio "volumedetect" | awk '/mean_volume|max_volume|histogram_/ {print}'

echo
echo "== Trailer overall waveform stats =="
ffmpeg_audio "astats=metadata=0:reset=0" | awk '
    /Overall/ {capture=1; print; next}
    capture && /(DC offset|Min level|Max level|Peak level dB|RMS level dB|RMS peak dB|RMS trough dB|Number of samples)/ {print}
  '

echo
echo "== Trailer silence check =="
silence_output="$(
  ffmpeg_audio "silencedetect=noise=-45dB:d=0.2" | awk '/silence_(start|end)/ {print}'
)"
if [[ -z "$silence_output" ]]; then
  echo "No silence events detected at noise=-45dB, duration=0.2s."
else
  echo "$silence_output"
fi

if [[ -s "$extras_file" ]]; then
  echo
  echo "== Embedded extras media streams =="
  while IFS= read -r extra_url; do
    name="$(basename "${extra_url%%\?*}")"
    echo "-- $name"
    ffprobe \
      -v error \
      -show_entries stream=index,codec_type,codec_name,sample_rate,channels,channel_layout,width,height,r_frame_rate,avg_frame_rate,bit_rate \
      -of compact=p=0:nk=0 \
      "$extra_url"
  done < "$extras_file"
fi

echo
echo "Audit does not store official audio or derived clips."
