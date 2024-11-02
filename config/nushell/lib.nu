export def init-path [path?: path] {
  let p = (if ($in != null) { $in } else { $path })
  let parent = $p | path dirname
  if not ($parent | path exists) {
    mkdir $parent
  }
  $p
}

