import duktape
import logging
import strformat
import ../scripts
import ../common

var logger = newLogger("fpga/hooks")

create_event_type("fpga_read")

proc read_hook*(indicator: uint32, value: uint32): uint32 =
  logger.log(lvlInfo, &"> read_hook({indicator}, {value})")
  for c in get_handlers("fpga_read"):
    logger.log(lvlInfo, &"< {c}({indicator}, {value})")
    discard ctx.duk_get_global_string(c)
    ctx.duk_push_int(cast[cint](indicator))
    ctx.duk_push_int(cast[cint](value))
    ctx.duk_call(2)

    return ctx.duk_get_int(0).uint32


proc initialize() =
  logger.log(lvlInfo, "initialize()")
  ctx.duk_eval_string("""
  println("Test!");
  println("" + register_cb)
  register_cb("fpga_read", function(a, b) {
  println("foo | " + a + " " + b);
  });""")
inits.add proc() = initialize()