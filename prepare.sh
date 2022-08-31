#!/bin/bash
set -e

OUTD="${2:-outd}"
FONTSTYLEDIR="${OUTD}/fontstyles"
FONTFILEDIR="${OUTD}/fonts"
FONTHOSTDIR="../fonts"
LOG="log.txt"

echo "==================== $(date --iso-8601=seconds) ===================="

mkdir -p "${FONTSTYLEDIR}"

for fontfamily in {Noto+Sans,Noto+Serif,Inconsolata,Bitter,Open+Sans,Roboto,Roboto+Slab,Lato,Source+Sans+Pro,Merriweather,Montserrat,Libre+Franklin,Raleway,Roboto+Slab,Ubuntu}; do

fontdir="${FONTFILEDIR}/"
fontname=$(echo "$fontfamily" |  tr '[:upper:]' '[:lower:]' | sed 's/[^A-Za-z0-9 _\-]//g')
fontcssfile="${FONTSTYLEDIR}/${fontname}.css"
mkdir -p "${fontdir}"
touch "${fontcssfile}"

for fontweight in {black,bold,semibold,regular,light,extralight}; do
for fontstyle in {regular,italic}; do
for fontsubset in {latin,latin-ext}; do
	fontcode="${fontname}_${fontweight}_${fontstyle}_${fontsubset}"

	echo "==== ==== ==== ==== ${fontcode} @ $(date --iso-8601=seconds)" | tee -a ${LOG}
	gapiurl="https://fonts.googleapis.com/css?family=${fontfamily}:${fontweight}${fontstyle}&subset=${fontsubset}&display=swap"
	fontcss=$(curl -s "${gapiurl}")
	echo "gapiurl=${gapiurl}" | tee -a ${LOG}
	if $( echo "${fontcss}" | grep -q -e "400: Missing font family" -e "not available"); then
		echo "error: unavailable=${gapiurl}" | tee -a ${LOG}
		continue;
	fi
	#echo "fontcss=${fontcss}" | tee -a ${LOG}

	fonturl=$(echo "${fontcss}" | grep "src:.*url" | sed 's/^.*url(\(.*\)) format(\(.*\)).*$/\1/g')
	fonturlfile=$(basename "${fonturl}")
	fonturlpath=$(dirname "${fonturl}" | sed 's#^.*\.com/s/##g')
	fontfile="${fontdir}/${fonturlpath}/${fontcode}.font"
	echo "fonturl=${fonturl}" | tee -a ${LOG}
	echo "fonturlpath=${fonturlpath}" | tee -a ${LOG}
	mkdir -p "${fontdir}/${fonturlpath}"
	if [ -f "${fontfile}" ]; then
		echo "info: skipped=${fontfile}" | tee -a ${LOG}
		continue;
	fi
	curl -s "${fonturl}" >> ${fontfile}

	csssrcs="  src: local('')"
	for format in {ttf,eot,svg,woff,woff2}; do
		echo "fontforge -quiet -lang=ff -c 'Open(\$1); Generate(\$2); Close();' ${fontfile} ${fontfile}.${format}"
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

