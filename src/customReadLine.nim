include inclrtl
# import strutils, termios
proc c_fgets(c: cstring, n: cint, f: File): cstring {.importc: "fgets", header: "<stdio.h>", tags: [ReadIOEffect].}
proc c_clearerr(f: File) {.importc: "clearerr", header: "<stdio.h>".}
template sysFatal(exc, msg) =
  raise newException(exc, msg)
proc raiseEIO(msg: string) {.noinline, noreturn.} =
  sysFatal(IOError, msg)
proc c_ferror(f: File): cint {.
  importc: "ferror", header: "<stdio.h>", tags: [].}
proc strerror(errnum: cint): cstring {.importc, header: "<string.h>".}
proc raiseEOF() {.noinline, noreturn.} =
  sysFatal(EOFError, "EOF reached")
var 
    errno {.importc, header: "<errno.h>".}: cint 
    EINTR {.importc: "EINTR", header: "<errno.h>".}: cint

proc checkErr(f: File) =
  when not defined(NimScript):
    if c_ferror(f) != 0:
      let msg = "errno: " & $errno & " `" & $strerror(errno) & "`"
      c_clearerr(f)
      raiseEIO(msg)
  else:
    # shouldn't happen
    quit(1)
proc customReadLine*(f: File, line: var TaintedString): bool {.tags: [ReadIOEffect],
              benign.} =
  ## reads a line of text from the file `f` into `line`. May throw an IO
  ## exception.
  ## A line of text may be delimited by ``LF`` or ``CRLF``. The newline
  ## character(s) are not part of the returned string. Returns ``false``
  ## if the end of the file has been reached, ``true`` otherwise. If
  ## ``false`` is returned `line` contains no new data.
  proc c_memchr(s: pointer, c: cint, n: csize_t): pointer {.importc: "memchr", header: "<string.h>".}

  var pos = 0

  # Use the currently reserved space for a first try
  var sp = max(line.string.len, 80)
  line.string.setLen(sp)

  while true:
    # memset to \L so that we can tell how far fgets wrote, even on EOF, where
    # fgets doesn't append an \L
    for i in 0..<sp: line.string[pos+i] = '\L'

    while true:
      # fixes #9634; this pattern may need to be abstracted as a template if reused;
      # likely other io procs need this for correctness.
      discard c_fgets(addr line.string[pos], sp.cint, f)
      when not defined(NimScript):
        if errno == EINTR:
          errno = 0
          c_clearerr(f)
          continue
      checkErr(f)
      break

    let m = c_memchr(addr line.string[pos], '\L'.ord, cast[csize_t](sp))
    if m != nil:
      # \l found: Could be our own or the one by fgets, we're done either way
      var last = cast[ByteAddress](m) - cast[ByteAddress](addr line.string[0])
      if last > 0 and line.string[last-1] == '\c':
        line.string.setLen(last-1)
        return last > 1 
        # We have to distinguish between two possible cases:
        # \0\l\0 => line ending in a null character.
        # \0\l\l => last line without newline, null was put there by fgets.
      elif last > 0 and line.string[last-1] == '\0':
        if last < pos + sp - 1 and line.string[last+1] != '\0': last.dec
      line.string.setLen(last)
      return last > 0 
    else: sp.dec
    # No \l found: Increase buffer and read more
    inc(pos, sp)
    sp = 128 # read in 128 bytes at one time
    line.string.setLen(pos+sp)

proc customReadLine*(f: File): TaintedString {.tags: [ReadIOEffect], benign.} =
  ## reads a line of text from the file `f`. May throw an IO exception.
  ## A line of text may be delimited by ``LF`` or ``CRLF``. The newline
  ## character(s) are not part of the returned string.
  result = TaintedString(80.newStringOfCap)
  if not customReadLine(f, result): raiseEOF()