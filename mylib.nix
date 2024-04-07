{
  self,
  lib,
}: rec {
  impurePathRoot = "/Users/logan/Projects/.dotfiles";
  impurePath = path: let
    rootStr = toString self;
    pathStr = toString path;
  in
    assert lib.assertMsg
    (lib.hasPrefix rootStr pathStr)
    "${pathStr} does not start with ${rootStr}";
      impurePathRoot + lib.removePrefix rootStr pathStr;
}
