# Package

version       = "0.1.0"
author        = "Jessica (nekoknot)"
description   = "A MITM library for FRC to (eventually) view/modify FPGA and CAN communication"
license       = "MIT"
srcDir        = "src"
namedBin["frc_interceptor"] = "frc_interceptor.so"

# Dependencies

requires "nim >= 1.4.4"
requires "nimgen >= 0.1.4"

skipDirs = @["tests","src"]

# Dependencies
import distros
import os

task setup, "Generate":
  var cmd_pre = "cd third_party"
  var cmd_post = ""
  if detectOs(Windows):
    cmd_pre &= "&&cmd /c \""
    cmd_post = "\""
  else:
    cmd_pre &= ";"

  if not existsFile("third_party/duktape/duktape_sys.nim"):
    exec cmd_pre & "nimgen duktape.cfg" & cmd_post


before build:
    setupTask()
  
