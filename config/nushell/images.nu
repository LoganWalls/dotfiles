export alias viu = viu --transparent

# View SVGs in the terminal
export def svgcat [
  path?: path, # The SVG file to read (defaults to STDIN)
  --dpi: int = 96, # DPI to use when rasterizing the SVG
  --zoom: int = 6, # Zoom factor to use when rasterizing the SVG
  ...args # Remaining arguments are passed to `viu`
] {
    let input = if ($path | is-not-empty) { cat $path } else { $in }
    $input | rsvg-convert --dpi-x $dpi --dpi-y $dpi --zoom $zoom | viu - ...$args
}

# View images in the terminal
export def icat [
    path?: path, # The file to read (defaults to STDIN)
    ...args # Remaining arguments are passed to `viu`
  ] {
    if ($path | is-empty) {
      $in | viu - ...$args
    } else if (($path | path parse | get extension) == "svg") {
      svgcat $path ...$args
    } else {
      viu $path ...$args
    }
  }

