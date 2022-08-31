# wordpress-google-font-replacements
A script and template for somewhat easy removal of loading fonts from google servers.


# Dependencies

bash, curl, sed, grep, fontforge

# Usage

Edit the foor-loops in `prepare.sh` to include font-families,font-styles,font-weights; as desired.
Depending on setup, change of the `FONTHOSTDIR` variable might be beneficial as well (e.g.: single font host serving all font data).
Execute `prepare.sh` which will download every one of the resulting fonts from google individually, by default into `./outd/fonts/`.
For every resulting font, conversion to various formats are performed.
For every font-family, a CSS stylesheet will be generated that defines all the requested fonts, by default into `./outd/fontstyles/`.

Copy over the `outd/fonts` and `outd/fontstyle` directories to your wordpress instance, eg.:
`scp -r outd/fonts outd/fontstyles serveradmin@server.com:/var/www/mywordpress/wp-content/themes/`

For you wordpress instance, copy `gdpr.php` to your wordpress child themes folder and add  `include 'gdpr.php';` to it's `function.php`.
For some of the wordpress default themes and some more, `gdpr.php` automatically detects if the functions loading fonts from google are enqueued and, dequeues them and loads respective stylesheets providing the originally used font definitions.
If your theme is not yet handled, search the parent themes' `functions.php` for where the google reference is added and under what name it is enqueued, add necessary fonts to `prepare.sh`, add a new rule to `gdpr.php`.

Not limited to wordpress per se, remove google references and include relevant CSS stylesheets, from whatever.

# Notes

Currently more font-formats are generated than referenced and therefore never used (only `woff2` and `woff` are active).
You might either add them in the `prepare.sh` script to be referenced, exclude them in `prepare.sh` from beeing generated or just not copy them to your server(s).

# References

- https://sicher3.de/google-fonts-checker/
- https://crunchify.com/wordpress-google-fonts-load-locally/
- https://fonts.google.com/
- https://developers.google.com/fonts/docs/getting_started
- https://bigelowandholmes.typepad.com/bigelow-holmes/2015/07/on-font-weight.html
- https://google-webfonts-helper.herokuapp.com/
