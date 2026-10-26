#!/bin/sh
set -eu

dir=$1
title=${2:-$1}
yaml() { sed -n "s/^ *$1: *\"\(.*\)\".*/\1/p" style.yaml | head -n 1; }
name=$(yaml name)
bg=$(yaml bg)
text=$(yaml text)
accent=$(yaml accent)
on_accent=$(yaml on_accent)

cat <<EOF
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$name — $title</title>
<style>
  body { margin: 0; background: $bg; color: $text; font: 16px/1.4 system-ui, sans-serif; }
  main { max-width: 1280px; margin: 0 auto; padding: 24px 16px 48px; display: grid; gap: 16px; }
  img { width: 100%; height: auto; display: block; border-radius: 8px; }
  a.pdf { justify-self: center; padding: 12px 24px; border-radius: 12px;
          background: $accent; color: $on_accent; font-weight: 600; text-decoration: none; }
</style>
</head>
<body>
<main>
EOF
for f in $(ls "$dir"/slide-*.png | sort -V); do
  echo "  <img src=\"$(basename "$f")\" alt=\"\" loading=\"lazy\">"
done
cat <<EOF
  <a class="pdf" href="$dir.pdf" download>Скачать PDF</a>
</main>
</body>
</html>
EOF
