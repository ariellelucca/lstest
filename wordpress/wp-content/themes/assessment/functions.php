<?php
/**
 * Theme functions.
 */

/**
 * Enqueue scripts/styles.
 *
 * @return void
 */
function headless_scripts() {
    wp_enqueue_style( 'headless-style', get_template_directory_uri() . '/style.css', array(), rand() );

    $asset_uri   = trailingslashit(get_template_directory_uri()) . 'assets/build/';
    $asset_root  = trailingslashit(get_template_directory()) . 'assets/build/';
    $asset_files = glob($asset_root . '*.asset.php');

    // Enqueue webpack loader.js, if it exists.
    if (true === is_readable($asset_root . 'loader.js')) {
        wp_enqueue_script(
            'assessment/runtime',
            $asset_uri . 'loader.js',
            array(),
            filemtime($asset_root . 'loader.js')
        );
    }

    foreach ($asset_files as $asset_file) {
        $asset_script = require($asset_file);

        $asset_filename = basename($asset_file);

        $asset_slug_parts = explode('.asset.php', $asset_filename);
        $asset_slug       = array_shift($asset_slug_parts);

        $asset_handle = sprintf('assessment/%s', $asset_slug);

        $stylesheet_path = $asset_root . $asset_slug . '.css';
        $stylesheet_uri  = $asset_uri . $asset_slug . '.css';

        $javascript_path = $asset_root . $asset_slug . '.js';
        $javascript_uri  = $asset_uri . $asset_slug . '.js';

        if (true === is_readable($stylesheet_path)) {
            $style_dependencies = [];

            wp_enqueue_style(
                $asset_handle,
                $stylesheet_uri,
                array(),
                $asset_script['version']
            );
        }

        if (true === is_readable($javascript_path)) {
            wp_enqueue_script(
                $asset_handle,
                $javascript_uri,
                $asset_script['dependencies'],
                $asset_script['version']
            );
        }
    }
}

add_action( 'wp_enqueue_scripts', 'headless_scripts' );
