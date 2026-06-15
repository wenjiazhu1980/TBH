#!/usr/bin/env bash
set -euo pipefail

app_url="${APP_URL:-https://store.steampowered.com/app/3678970/TBH_Task_Bar_Hero/}"
keep_frames="${KEEP_FRAMES:-0}"
tmpdir="$(mktemp -d)"
html_file="$tmpdir/steam-app.html"
urls_file="$tmpdir/battlescene-urls.txt"

cleanup() {
  if [[ "$keep_frames" == "1" ]]; then
    echo "Kept temporary frames in: $tmpdir"
  else
    rm -rf "$tmpdir"
  fi
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
require_tool python3
require_tool ffprobe
require_tool ffmpeg

curl -L --compressed -A "Mozilla/5.0" -s "$app_url" > "$html_file"

perl -0777 -ne '
  $base = "";
  if (/data-store_page_asset_url="&quot;([^&]+)&quot;"/) {
    $base = $1;
    $base =~ s#\\/#/#g;
    $base =~ s/&amp;/&/g;
  }

  if (/&quot;extras\\\/battlescene&quot;:\[(.*?)\]/s) {
    $block = $1;
    while ($base ne "" && $block =~ m{&quot;urlPart&quot;:&quot;(extras\\/[^&]+?\.(?:mp4|webm))&quot;}g) {
      $part = $1;
      $part =~ s#\\/#/#g;
      $u = $base;
      $u =~ s/%s/$part/;
      print "$u\n";
    }
  }

  while (m{(https://shared\.(?:fastly|akamai)\.steamstatic\.com/store_item_assets/steam/apps/3678970/extras/[^" <]+?\.(?:mp4|webm)\?t=\d+)}g) {
    $u = $1;
    print "$u\n" if $u =~ /8d14259cbca180cea4e366f03ffbce01/;
  }
' "$html_file" | sort -u > "$urls_file"

if [[ ! -s "$urls_file" ]]; then
  echo "could not find Steam battlescene media URLs in: $app_url" >&2
  exit 1
fi

webm_url="$(awk '/\.webm/ { print; exit }' "$urls_file")"
preferred_url="${webm_url:-$(head -n 1 "$urls_file")}"

echo "Source page: $app_url"
echo "Battle scene URLs:"
sed 's/^/  /' "$urls_file"
echo

echo "== Stream metadata =="
while IFS= read -r media_url; do
  name="$(basename "${media_url%%\?*}")"
  echo "-- $name"
  ffprobe \
    -v error \
    -show_entries format=duration,format_name,bit_rate \
    -show_entries stream=index,codec_type,codec_name,width,height,pix_fmt,r_frame_rate,avg_frame_rate,duration,bit_rate,nb_frames \
    -of json \
    "$media_url"
done < "$urls_file"

echo
echo "== Frame count =="
while IFS= read -r media_url; do
  name="$(basename "${media_url%%\?*}")"
  echo "-- $name"
  ffprobe \
    -v error \
    -count_frames \
    -show_entries format=duration \
    -show_entries stream=index,codec_type,codec_name,width,height,r_frame_rate,avg_frame_rate,duration,nb_read_frames \
    -of compact=p=0:nk=0 \
    "$media_url"
done < "$urls_file"

echo
echo "== Sample frame timeline =="
ffmpeg \
  -hide_banner \
  -nostdin \
  -v info \
  -i "$preferred_url" \
  -vf "select='eq(n,0)+eq(n,15)+eq(n,60)+eq(n,90)+eq(n,165)+eq(n,183)',showinfo" \
  -vsync vfr \
  -f null - 2>&1 | awk '/Input #|Stream #|showinfo|frame=/ {print}'

metrics_dir="$tmpdir/frame-metrics"
mkdir -p "$metrics_dir"
for timestamp in 0.5 3.0 5.5; do
  ffmpeg \
    -hide_banner \
    -nostdin \
    -v error \
    -ss "$timestamp" \
    -i "$preferred_url" \
    -frames:v 1 \
    "$metrics_dir/battlescene-${timestamp}s.png"
done

echo
echo "== Sample frame geometry =="
python3 - "$metrics_dir" <<'PY'
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for frame geometry analysis: {exc}", file=sys.stderr)
    sys.exit(2)

frame_dir = Path(sys.argv[1])
paths = sorted(frame_dir.glob("battlescene-*.png"))
if not paths:
    print("no sampled frames found for geometry analysis", file=sys.stderr)
    sys.exit(1)

platform_width_ratios = []
platform_left_ratios = []
platform_right_ratios = []
platform_top_ratios = []
platform_bottom_ratios = []

for path in paths:
    image = Image.open(path).convert("RGB")
    width, height = image.size
    pixels = image.load()
    warm_rows = []
    minimum_warm_hits_per_row = max(48, int(width * 0.08))

    for y in range(int(height * 0.68), height):
        xs = []
        for x in range(width):
            red, green, blue = pixels[x, y]
            is_warm_ground = (
                red >= 130
                and 70 <= green <= 230
                and blue <= 140
                and red > green * 1.05
                and green > blue * 1.05
            )
            if is_warm_ground:
                xs.append(x)

        if len(xs) >= minimum_warm_hits_per_row:
            warm_rows.append((y, min(xs), max(xs), len(xs)))

    groups = []
    current = []
    for row in warm_rows:
        if not current or row[0] <= current[-1][0] + 2:
            current.append(row)
        else:
            groups.append(current)
            current = [row]
    if current:
        groups.append(current)

    candidates = []
    for group in groups:
        min_y = min(row[0] for row in group)
        max_y = max(row[0] for row in group)
        min_x = min(row[1] for row in group)
        max_x = max(row[2] for row in group)
        band_width = max_x - min_x + 1
        band_height = max_y - min_y + 1
        total_hits = sum(row[3] for row in group)
        if band_width >= width * 0.55 and band_height >= height * 0.14:
            candidates.append((band_width * band_height, total_hits, min_x, min_y, max_x, max_y))

    if not candidates:
        print(f"{path.name}: lower warm platform not detected", file=sys.stderr)
        sys.exit(1)

    _, total_hits, min_x, min_y, max_x, max_y = max(candidates)
    band_width = max_x - min_x + 1
    band_height = max_y - min_y + 1

    left_ratio = min_x / width
    right_ratio = (max_x + 1) / width
    width_ratio = band_width / width
    top_ratio = min_y / height
    bottom_ratio = (max_y + 1) / height

    platform_left_ratios.append(left_ratio)
    platform_right_ratios.append(right_ratio)
    platform_width_ratios.append(width_ratio)
    platform_top_ratios.append(top_ratio)
    platform_bottom_ratios.append(bottom_ratio)

    print(
        f"{path.name}: "
        f"lower_ground_bbox=x:{min_x},y:{min_y},w:{band_width},h:{band_height},warm_pixels:{total_hits}, "
        f"x_ratio={left_ratio:.3f}-{right_ratio:.3f}, "
        f"width_ratio={width_ratio:.3f}, "
        f"y_ratio={top_ratio:.3f}-{bottom_ratio:.3f}"
    )

print(
    "summary: "
    f"width_ratio={min(platform_width_ratios):.3f}-{max(platform_width_ratios):.3f}, "
    f"x_start={min(platform_left_ratios):.3f}-{max(platform_left_ratios):.3f}, "
    f"x_end={min(platform_right_ratios):.3f}-{max(platform_right_ratios):.3f}, "
    f"y_start={min(platform_top_ratios):.3f}-{max(platform_top_ratios):.3f}, "
    f"y_end={min(platform_bottom_ratios):.3f}-{max(platform_bottom_ratios):.3f}"
)
PY

if [[ "$keep_frames" == "1" ]]; then
  echo
  echo "== Extracted sample frames =="
  for timestamp in 0.5 2.0 3.0 5.5; do
    frame_path="$tmpdir/battlescene-${timestamp}s.png"
    ffmpeg \
      -hide_banner \
      -nostdin \
      -v error \
      -ss "$timestamp" \
      -i "$preferred_url" \
      -frames:v 1 \
      "$frame_path"
    echo "$frame_path"
  done
fi

echo
echo "Audit does not store official video frames unless KEEP_FRAMES=1 is set."
