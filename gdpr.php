<?php
//remove all queued styles from originals array and if anything is removed add replacement styles
function gdpr_fixup_style($originals, $replacements) {
        $removed=0;
        foreach ($originals as $original) {
                if ( wp_style_is( $original, 'enqueued' ) ) {
                        wp_dequeue_style($original);
                        $removed++;
                }
        }
        $counter=0;
        if ( $removed > 0) {
                foreach ($replacements as $replacement) {
                        wp_enqueue_style('gdpr-font-style-replacement-'.$counter,$replacement);
                        $counter++;
                }
        }
}
//search for enqueued styles that load google fonts and replace them
function gdpr_fixup() {
        $fsbase=get_theme_root_uri().'/fontstyles';
        gdpr_fixup_style(array('twentytwelve-fonts'), array($fsbase.'/opensans.css'));
        gdpr_fixup_style(array('twentythirteen-fonts'), array($fsbase.'/sourcesanspro.css',$fsbase.'/bitter.css'));
        gdpr_fixup_style(array('twentyfourteen-fonts','twentyfourteen-lato'), array($fsbase.'/lato.css'));
        gdpr_fixup_style(array('twentyfifteen-fonts'), array($fsbase.'/notosans.css',$fsbase.'/notoserif.css',$fsbase.'/incsonsolata.css'));
        gdpr_fixup_style(array('twentysixteen-fonts'), array($fsbase.'/merriweather.css',$fsbase.'/montserrat.css',$fsbase.'/incsonsolata.css'));
        gdpr_fixup_style(array('twentyseventeen-fonts'), array($fsbase.'/opensans.css'));
        gdpr_fixup_style(array('et-divi-open-sans'), array($fsbase.'/opensans.css'));
        gdpr_fixup_style(array('hemingway-googleFonts','hemingway-block-editor-styles-font'), array($fsbase.'/lato.css',$fsbase.'/raleway.css'));
}
add_action( 'wp_enqueue_scripts', 'gdpr_fixup', 11 );
?>
