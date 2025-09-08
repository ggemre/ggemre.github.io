#!/usr/bin/env bash
set -euo pipefail

SRC=./src
DEST=./public

# Clean output directory
rm -rf "$DEST"
mkdir -p "$DEST"

# Find all files in src
find "$SRC" -type f | while read -r file; do
  rel="${file#"$SRC"/}"            # relative path (strip ./src/)
  base="${rel%.*}"                 # path without extension
  ext="${rel##*.}"                 # extension

  case "$ext" in
    html)
      # Copy HTML as-is
      mkdir -p "$DEST/$(dirname "$rel")"
      cp "$file" "$DEST/$rel"
      echo "Copied HTML: $rel"
      ;;
    typ)
      # Compile Typst to PDF
      # TODO: manage template.typ files !!
      out="$DEST/$base.pdf"
      mkdir -p "$(dirname "$out")"
      typst compile "$file" "$out"
      echo "Compiled Typst → PDF: $rel → $base.pdf"
      ;;
    md)
      # Convert Markdown to HTML
      out="$DEST/$base.html"
      mkdir -p "$(dirname "$out")"
      pandoc "$file" -o "$out"
      echo "Converted Markdown → HTML: $rel → $base.html"
      ;;
    *)
      echo "Skipping unsupported file: $rel"
      ;;
  esac
done

