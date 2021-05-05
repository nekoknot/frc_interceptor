import logging

proc newLogger*(section = "main"): ConsoleLogger =
  newConsoleLogger(fmtStr="[" & section & "] - [$levelname] - ")

var logger = newLogger("common")

var inits* = newSeq[proc()]()

var initialized = false
proc initialize_all*() =
  if not initialized:
    logger.log(lvlInfo, "[initialize] Calling initialization functions")
    for i in inits:
      i()
    initialized = true