#!/bin/bash

declare -r FORMAT_SUCCESS="\e[1;32m[SUCCESS]\e[0m"
declare -r THUMBNAILS_DIR=".Thumbnails"
declare -r README="README.md"
declare -r BASE_URL="https://github.com/druxorey/tmp/raw/refs/heads/main"

function main() {
	mkdir -p "$THUMBNAILS_DIR"
	for file in {Alucard,Dracula}/*.jxl; do
		[ -e "$file" ] || continue
		local filename=$(basename "$file")
		magick "$file" -resize 1280x720 -quality 50 "$THUMBNAILS_DIR/${filename%.*}.webp"
	done

	# Start building the table block
	{
		echo "| Alucard | Dracula |"
		echo "| ------- | ------- |"
	} > galleryTemporal.md

	# Get list of unique IDs based on Dracula files
	for draculaFile in Dracula/D*.jxl; do
		[ -e "$draculaFile" ] || continue

		local id=$(basename "${draculaFile%.jxl}" | cut -c 2-)

		alucardCell="<div align=\"center\"><a href=\"Alucard/A$id.jxl\"><img src=\"$THUMBNAILS_DIR/A$id.webp\"></a><br><a href=\"$BASE_URL/Alucard/A$id.jxl\">Download</a></div>"
		draculaCell="<div align=\"center\"><a href=\"Dracula/D$id.jxl\"><img src=\"$THUMBNAILS_DIR/D$id.webp\"></a><br><a href=\"$BASE_URL/Dracula/D$id.jxl\">Download</a></div>"

		echo "| $alucardCell | $draculaCell |" >> galleryTemporal.md
	done

	# Replace the gallery section in the README
	sed -i '/## Gallery/,/## License/ {
		/## Gallery/b
		/## License/b
		d
	}' "$README"

	# Insert new content after ## Gallery
	sed -i '/## Gallery/r galleryTemporal.md' "$README"
	rm galleryTemporal.md

	printf "%b Gallery successfully updated!\n" "$FORMAT_SUCCESS"

	return 0
}

main "$@"
