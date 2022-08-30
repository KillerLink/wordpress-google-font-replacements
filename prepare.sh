#!/bin/bash
set -e

OUTD="${2:-outd}"
FONTSTYLEDIR="${OUTD}/fontstyles"
FONTFILEDIR="${OUTD}/fonts"
FONTHOSTDIR="../fonts"
LOG="log.txt"
mkdir -p "${FONTSTYLEDIR}"

for fontfamily in {Noto+Sans,Noto+Serif,Inconsolata,Bitter,Open+Sans,Roboto,Roboto+Slab,Lato,Source+Sans+Pro,Merriweather,Montserrat,Libre+Franklin,Raleway,Roboto+Slab}; do

fontdir="${FONTFILEDIR}/"
fontname=$(echo "$fontfamily" |  tr '[:upper:]' '[:lower:]' | sed 's/[^A-Za-z0-9 _\-]//g')
fontcssfile="${FONTSTYLEDIR}/${fontname}.css"
mkdir -p "${fontdir}"
touch "${fontcssfile}"

for fontweight in {black,bold,semibold,regular,light,extralight}; do
for fontstyle in {regular,italic}; do
for fontsubset in {latin,latin-ext}; do

	echo "==== ==== ==== ====" >> ${LOG}
	gapiurl="https://fonts.googleapis.com/css?family=${fontfamily}:${fontweight}${fontstyle}&subset=${fontsubset}&display=swap"
	fontcss=$(curl "${gapiurl}")
	echo "gapiurl=${gapiurl}" >> log.txt
	if $( echo "${fontcss}" | grep -q -e "400: Missing font family" -e "not available"); then
		echo "error: unavailable=${gapiurl}" >> ${LOG}
		continue;
	fi
	echo "fontcss=${fontcss}" >> ${LOG}

	fonturl=$(echo "${fontcss}" | grep "src:.*url" | sed 's/^.*url(\(.*\)) format(\(.*\)).*$/\1/g')
	fonturlfile=$(basename "${fonturl}")
	fonturlpath=$(dirname "${fonturl}" | sed 's#^.*\.com/s/##g')
	fontcode="${fontname}_${fontweight}_${fontstyle}_${fontsubset}"
	fontfile="${fontdir}/${fonturlpath}/${fontcode}.font"
	echo "fonturl=${fonturl}" >> ${LOG}
	echo "fonturlpath=${fonturlpath}" >> ${LOG}
	mkdir -p "${fontdir}/${fonturlpath}"
	if [ -f "$FILE" ]; then
		echo "info: already=${fontfile}" >> ${LOG}
		continue;
	fi
	curl "${fonturl}" >> ${fontfile}

	csssrcs="  src: local('')"
	for format in {ttf,eot,svg,woff,woff2}; do
		echo "fontforge -lang=ff -c 'Open(\$1); Generate(\$2); Close();' ${fontfile} ${fontfile}.${format}"
	done | bash
	csssrcs+=$(echo -e ",\n     url(${FONTHOSTDIR}/${fonturlpath}/${fontcode}.font.woff2) format('woff2')")
	csssrcs+=$(echo -e ",\n     url(${FONTHOSTDIR}/${fonturlpath}/${fontcode}.font.woff) format('woff')")
	csssrcs+=$(echo -e ';')
	echo "/* ${fontfamily} ${fontweight} ${fontstyle} ${fontsubset}*/" >> ${fontcssfile}
	export csssrcs;
	echo "${fontcss}" | sed 's/^.*src.*$/${csssrcs}/g' | envsubst >> ${fontcssfile}

done
done
done
done

