import duktape/duktape_sys
export duktape_sys

import strutils
const sourcePath = currentSourcePath().split({'\\', '/'})[0..^2].join("/")
const headerduktape = sourcePath & "/duktape/duktape.h"

# These were macros that it didn't convert to nim

proc duk_create_heap_default*(): duk_context {.header: headerduktape.}
proc duk_eval_string*(ctx: duk_context, src: cstring) {.header: headerduktape.}

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