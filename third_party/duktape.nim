import duktape/duktape_sys
export duktape_sys

import strutils
import tables
import macros

const sourcePath = currentSourcePath().split({'\\', '/'})[0..^2].join("/")
const headerduktape = sourcePath & "/duktape/duktape.h"

# These were macros that it didn't convert to nim

proc duk_create_heap_default*(): duk_context {.header: headerduktape.}
proc duk_eval_string*(ctx: duk_context, src: cstring) {.header: headerduktape.}

let DUK_VARARGS* {.compileTime.}: cint = -1

#

let duk_alloc_function_null = cast[duk_alloc_function](0)
let duk_realloc_function_null = cast[duk_realloc_function](0)
let duk_free_function_null = cast[duk_free_function](0)
let heap_udata_null = cast[pointer](0)
let duk_fatal_function_null = cast[duk_fatal_function](0)

proc duk_create_heap*(alloc_func: duk_alloc_function=duk_alloc_function_null;
                     realloc_func: duk_realloc_function=duk_realloc_function_null;
                     free_func: duk_free_function=duk_free_function_null;
                     heap_udata: pointer=heap_udata_null;
                     fatal_handler: duk_fatal_function=duk_fatal_function_null
                     ): duk_context {.stdcall,
    importc: "duk_create_heap", header: headerduktape.}

#

proc duk_create_func_registry*(): TableRef[string, proc(x: duk_context)] =
  return newTable[string, proc(x: duk_context)]()


proc duk_register_functions*(ctx: duk_context, registry: TableRef[string, proc(x: duk_context)]) = 
  for v in registry.values:
    v(ctx)

macro duk_register*(registry: untyped, name: static[string], nargs: static[cint], p: untyped): untyped = 

  p.expectKind(nnkProcDef)
  
  result = newStmtList()
  result.add p

  result.add nnkStmtList.newTree(
    nnkProcDef.newTree(
      newIdentNode($p.name & "_register"),
      newEmptyNode(),
      newEmptyNode(),
      nnkFormalParams.newTree(
        newEmptyNode(),
        nnkIdentDefs.newTree(
          newIdentNode("ctx"),
          newIdentNode("duk_context"),
          newEmptyNode()
        )
      ),
      newEmptyNode(),
      newEmptyNode(),

      nnkStmtList.newTree(
        nnkCommand.newTree(
          newIdentNode("assert"),
          nnkInfix.newTree(
            newIdentNode("=="),
            newLit(0),
            nnkCall.newTree(
              nnkDotExpr.newTree(
                newIdentNode("ctx"),
                newIdentNode("duk_push_c_function")
              ),
              nnkCast.newTree(
                newIdentNode("duk_c_function"),
                newIdentNode($p.name)
              ),
              nnkCast.newTree(
                newIdentNode("cint"),
                newLit(nargs)
              )
            )
          )
        ),
        nnkCommand.newTree(
          newIdentNode("assert"),
          nnkInfix.newTree(
            newIdentNode("=="),
            newLit(1),
            nnkCall.newTree(
              nnkDotExpr.newTree(
                newIdentNode("ctx"),
                newIdentNode("duk_put_global_string")
              ),
              newLit(name)
            )
          )
        )
      )
    )
  )
  result.add nnkStmtList.newTree(
      nnkAsgn.newTree(
        nnkBracketExpr.newTree(
          newIdentNode($registry),
          newLit(name)
        ),
      newIdentNode($p.name & "_register")
      )
    )

  echo repr(result)

  return result

#

let duk_helpful_func_registry* =  duk_create_func_registry()

proc println(ctx: duk_context): cint {.duk_register(duk_helpful_func_registry, "println", 1).} =
  echo ctx.duk_to_string(0)
  ctx.duk_pop()