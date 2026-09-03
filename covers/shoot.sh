#!/bin/bash
# Renders cover-01.html .. cover-16.html to cover-NN.png, 1600x2560, headless.
# Waits for webfonts (Space Grotesk, IBM Plex Mono) before shooting so a cover
# never ships in a fallback font. Uses agent-browser (the `browser` skill),
# headless session named "covers" so it never collides with `rb` (headed).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
SESSION="covers"

agent-browser --session "$SESSION" set viewport 1600 2560

for n in $(seq -w 1 16); do
  html="file://$HERE/cover-$n.html"
  png="$HERE/cover-$n.png"
  agent-browser --session "$SESSION" open "$html"
  # wait for webfonts, then confirm the title is not rendered in a fallback font
  fam=$(agent-browser --session "$SESSION" eval "document.fonts.ready.then(()=>getComputedStyle(document.querySelector('h1')).fontFamily)" --json | grep -o 'Space Grotesk' || true)
  if [ -z "$fam" ]; then
    echo "WARN cover-$n: h1 font-family did not report Space Grotesk"
  fi
  agent-browser --session "$SESSION" screenshot "$png"
  echo "shot cover-$n.png"
done

agent-browser --session "$SESSION" close
