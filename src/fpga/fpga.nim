import register
import read_config
import strformat
import tables
import hooks
import ../common
import logging

var logger = newLogger("fpga/fpga")

var config: RegisterConfig
var config_path = "regs.cfg"

proc initialize() = 
  logger.log(lvlInfo, "initialize()")
  try:
      config = read_config(config_path)
      for reg in config.registers:
        logger.log(lvlInfo, &"[config] Add Register: {reg}")
        add_register(reg)

  except Exception:
    echo "Config Exception: " & getCurrentExceptionMsg()
    raise

inits.add proc() = initialize()


proc register_write_handler*(control: uint32, value: uint32) =
  if registers.contains(control):
    for reg in registers[control]:
      if reg.direction == WRITE:
        reg.set(value)
    if config.print_regs:
      logger.log(lvlInfo, &"[write] | {value:08x} | 0x{control:08x}")
  else:
    if config.print_unknown:
      logger.log(lvlInfo, &"[write] | {value:08x} | 0x{control:08x}")

proc register_read_handler*(indicator: uint32, value: ptr uint32) =
  discard read_hook(indicator, value[])
  if registers.contains(indicator):
    for reg in registers[indicator]:
      if reg.direction == READ:
        reg.set(value[])
    if config.print_regs:
      logger.log(lvlInfo, &"[read]  | {value[]:08x} | 0x{indicator:08x}")
  else:
    if config.print_unknown:
      logger.log(lvlInfo, &"[read]  | {value[]:08x} | 0x{indicator:08x}")