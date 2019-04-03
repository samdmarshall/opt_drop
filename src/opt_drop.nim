# =======
# Imports
# =======

import os
import parseopt
import strutils

const
  AppName = "opt_drop"
  AppVersion = "0.1.0"

# ==========
# Main Entry
# ==========

var prev_opt: OptParser
var parse_as_arg_mode = false
var ignore_name = ""
var non_opts = newSeq[string]()
var p = initOptParser()
while true:
  p.next()
  if p.kind == cmdEnd:
    break
  if p.kind == cmdArgument or parse_as_arg_mode:
    if p.key.len > 0 and p.key != ignore_name:
      let path = p.key.expandTilde()
      let fullpath =
        if path.isAbsolute(): path
        else: getCurrentDir().joinPath(path)
      if fullpath.existsFile() or fullpath.existsDir():
        non_opts.add(fullpath)
  else:
    case p.kind
    of cmdShortOption, cmdLongOption:
      case p.key
      of "v", "version":
        echo(AppName & " v" & AppVersion)
        break
      of "h", "help":
        echo(AppName &
          " [-v|--version] [-h|--help] [[-n|--name] <name of command>] ...")
        break
      of "n", "name":
        ignore_name = p.val
      of "":
        parse_as_arg_mode = true
      else:
        discard
    else:
      break
  prev_opt.shallowCopy(p)
if non_opts.len > 0:
  echo(non_opts.join(" "))
quit(QuitSuccess)
