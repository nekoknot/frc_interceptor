import common
import duktape
import tables
import logging
import strformat

var logger = newLogger("scripts")

var event_handlers = initTable[string, seq[string]]()

proc get_handlers*(event_type: string): seq[string] =
  event_handlers[event_type]

proc create_event_type*(event_type: string) =
  if not event_handlers.contains(event_type): 
    event_handlers[event_type] = newSeq[string]()

proc fatal_handler(udata: pointer, msg: cstring) =
  logger.log(lvlFatal, msg)

var ctx* = duk_create_heap(fatal_handler=cast[duk_fatal_function](fatal_handler))

let registry = duk_create_func_registry()

proc register_cb(ctx: duk_context): cint {.duk_register(registry, "register_cb", 2).} =
  logger.log(lvlInfo, &"[register_cb] register_cb({ctx.duk_get_type(0)}, {ctx.duk_get_type(1)})")
  if ctx.duk_is_function(1) != 0:
    logger.log(lvlInfo, "[register_cb] is_function")
  let event_type: string = $ctx.duk_require_string(0)
  ctx.duk_require_function(1)
  if not event_handlers.contains(event_type): 
    logger.log(lvlWarn, "[register_cb] Could not find event type")
    ctx.duk_push_false()
  else:
    var handler = event_handlers[event_type]
    let name = &"_cb_{event_type}_{$event_handlers[event_type].len}"
    logger.log(lvlInfo, &"[register_cb] Registered: {name}")
    discard duk_put_global_string(ctx, name)
    event_handlers[event_type].add name
    logger.log(lvlInfo, &"Handler count: {event_handlers[event_type].len}")
    ctx.duk_push_true()


proc initialize() = 
  logger.log(lvlInfo, "initialize()")
  ctx.duk_register_functions(duk_helpful_func_registry)
  ctx.duk_register_functions(registry)
inits.add proc() = initialize()
  