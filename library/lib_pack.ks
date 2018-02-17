
// lib_pack v1.0
// KerboScript packager and minifier with preprocessor support
// Originally developed by brantwedel

//#pack lib_pack 0.1.0 "KerboScript packager and minifier"

@LAZYGLOBAL off.

local parameter
  _arg1 is "__undefined__",
  _arg2 is "__undefined__",
  _arg3 is "__undefined__",
  _arg4 is "__undefined__",
  _arg5 is "__undefined__",
  _arg6 is "__undefined__",
  _arg7 is "__undefined__",
  _arg8 is "__undefined__",
  _arg9 is "__undefined__",
  _arg10 is "__undefined__".

global Pack is lexicon(
  "version", "0.1.0",
  "pack", _pack@,
  "minify", _pack@:bind("minify"),
  "parse", ksparse@
).

local option_templates to lex(
  "definitions", lex(
    "minimize_locals", false,
    "embed", false,
    "comments", true,
    "multiline", true,
    "minimize", false,
    "deploy", false,
    "ipu", 5000,
    "library", "0:/library/*",
    "defs", true,
    "keep_defines", true
  ),
  "default", lex(
    "minimize_locals", false,
    // "embed", "inline",
    "comments", true,
    "multiline", true,
    "minimize", false,
    "deploy", false,
    "ipu", 5000,
    "library", "0:/library/*",
    "defs", true,
    "verbose", false,
    "keep_defines", false
  ),
  "minify", lex(
    "minimize_locals", true,
    // "embed", false,
    "comments", false,
    "multiline", true,
    "minimize", true,
    "defs", true
  ),
  "embed", lex(
    "embed", "inline",
    "comments", true
  ),
  "pack", lex(
    "minimize_locals", true,
    "embed", "inline",
    "comments", false,
    "multiline", true,
    "minimize", true,
    "defs", true
  ),
  "expand", lex(
    "minimize_locals", false,
    "embed", "expand",
    "comments", true,
    "multiline", true,
    "minimize", false,
    "defs", true
  )
).

if _arg1 <> "__undefined__" {
  _pack(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg9, _arg10).
}

function _pack {
  // handle arguments by type / pattern
  local parameter
    _arg1 is "__undefined__",
    _arg2 is "__undefined__",
    _arg3 is "__undefined__",
    _arg4 is "__undefined__",
    _arg5 is "__undefined__",
    _arg6 is "__undefined__",
    _arg7 is "__undefined__",
    _arg8 is "__undefined__",
    _arg9 is "__undefined__",
    _arg10 is "__undefined__".

  local args to list(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg9, _arg10).
  until args:length = 0 or (not args[args:length-1]:istype("string") or args[args:length-1] <> "__undefined__") {
    args:remove(args:length - 1).
  }

  if args:length = 0 {
    print "Error: No Arguments Provided.".
    return.
  }

  local _fname to false.
  local _fname_out to false.
  local _options to option_templates["default"]:copy.
  local i to 0.
  for arg in args {
    set i to i + 1.
    if arg:istype("path") or (arg:istype("string") and (arg:contains(".ks") or arg:contains("/")) and not arg:contains("@")) {
      // a string or path to a file was passed
      // TODO check for directory
      if not _fname {
        // first filename is input
        set _fname to arg.
      } else if _fname_out {
        // next filename is output
        set _fname_out to arg.
      }
    } else if arg:istype("string") and not arg:contains("@") {
      // a string containing a template name was passed
      set arg to option_templates[arg].
      for k in arg:keys {
        if not _options:haskey(k) or not arg[k]:istype("boolean") or arg[k] = false {
          set _options[k] to arg[k].
        } else if _options[k]:istype("boolean") {
          // options is boolean, overwrite with arg[k]
          set _options[k] to arg[k].
        } else {
          // options has a truthy value, and arg[k] was true, don't overwrite
        }
      }
    } else if arg:istype("string") and arg:contains("@") {
      // a list of directive definitions was passed
      if _options["defs"] = true {
        set _options["defs"] to list().
      }
      set arg to arg:split(" ").
      for def in arg {
        set def to def:replace("@", ""):trim.
        if def <> "" and not _options["defs"]:contains("@" + def) {
          print "#define @" + def.
          _options["defs"]:add("@" + def).
        }
      }
    } else if arg:istype("lexicon") {
      // a lexicon of options was passed
      for k in arg:keys {
        if not _options:haskey(k) or not arg[k]:istype("boolean") or arg[k] = false {
          set _options[k] to arg[k].
        } else if _options[k]:istype("boolean") {
          // options is boolean, overwrite with arg[k]
          set _options[k] to arg[k].
        } else {
          // options has a truthy value, and arg[k] was true, don't overwrite
        }
      }
    } else {
      print "Argument #" + i + " Unrecognized: " + arg.
      return.
    }
  }

  if not (defined _ipu_bak) or config:ipu < _ipu_bak {
    global _ipu_bak to config:ipu.
  }

  // todo move these to file
  global pack_total_size to 0.
  global pack_run_once_list to list().

  set _options["filename"] to _fname.
  set _options["base_filename"] to _fname.

  print " ".
  print "Packing " + _fname + " ...".
  print " ".
  print _options:tostring:replace(char(10) + "[" + char(34), char(10)):replace(char(34) + "] = ", " = "):split(" items:"+char(10))[1].
  print " ".

  local _s to open(_fname):readall():string.

  set config:ipu to _options["ipu"].
  print "Overclocking IPU from " + _ipu_bak + " to " + config:ipu.
  print " ".
  wait 0.1.

  local _p to ksparse(_s, _options).

  if _p:istype("lexicon") {
    local v0 to getvoice(0).
    V0:PLAY( slideNOTE( 440,100, 0.1) ).
    print " ".
    print _p["error_type"] + " Error: " + _p["error"].
    print "  Context: " + _p["context"].
    print "  Location: " + _p["filename"] + " " + _p["line"] + ":" + _p["col"].
    print " ".
    set config:ipu to _ipu_bak.
    unset _ipu_bak.
    print "Reset IPU to " + config:ipu.
    print " ".
    unset pack_total_size.
    return _p.
  }

  local pk_name to _fname:replace(".ks", ".pak.ks").

  if (exists(pk_name)) {
    open(pk_name):clear().
  } else {
    create(pk_name).
  }
  open(pk_name):write(_p).

  compile pk_name.

  print " ".
  set config:ipu to _ipu_bak.
  unset _ipu_bak.

  print "Reset IPU to " + config:ipu.
  print " ".
  print "Entry:    " + _s:length.
  print "Total:    " + pack_total_size.
  print "Packed:   " + _p:length.
  print "Compiled: " + open(pk_name + "m"):size.
  print " ".
  unset pack_total_size.

  return lexicon("packed", _p).
}

local function check_defined {
  parameter name.
  if exists("temp-check-defined-" + name + ".ks") {
    deletepath("temp-check-defined-" + name + ".ks").
  }
  create("temp-check-defined-" + name + ".ks"):write("set temp_was_defined to false. if defined " + name + " { set temp_was_defined to true. }").
  runpath("temp-check-defined-" + name + ".ks").
  if exists("temp-check-defined-" + name + ".ks") {
    deletepath("temp-check-defined-" + name + ".ks").
  }
  if defined temp_was_defined {
    return temp_was_defined.
    unset temp_was_defined.
  }
  return false.
}

function find_library {
  parameter _name, _options.
  local _local is path(_name):parent.
  local _name to path(_name):changeextension("ks"):name.
  local _curr is path(_options["filename"]):parent.
  local _base is path(_options["base_filename"]):parent.
  local _working is PATH().

  local _vol1 is path("1:/").
  local _vol0 is path("0:/").

  local _lib to path(_options["library"]).

  local search_paths to list(
    _base:combine(_name),
    _base:combine("lib", "*", _name),
    _base:combine("library", "*", _name),
    _base:combine("*", _name),

    _working:combine(_name),
    _working:combine("lib", "*", _name),
    _working:combine("library", "*", _name),

    path(_lib:tostring:replace("*","")):combine(_name),

    _curr:combine(_name),
    _curr:combine("lib", "*", _name),
    _curr:combine("library", "*", _name),

    _local:combine(_name),
    _local:combine("lib", "*", _name),
    _local:combine("library", "*", _name),

    _base:root:combine(_name),
    _base:root:combine("lib", "*", _name),
    _base:root:combine("library", "*", _name),

    _vol1:root:combine(_name),
    _vol1:root:combine("lib", "*", _name),
    _vol1:root:combine("library", "*", _name),

    _vol0:root:combine(_name),
    _vol0:root:combine("lib", "*", _name),
    _vol0:root:combine("library", "*", _name),

    path(_lib):combine("*", _name)
  ).

  for sp in search_paths {
    //if exists(sp:tostring:replace("/*/", "/")) {
    //  return sp:tostring:replace("/*/", "/").
    //}
    if sp:tostring:contains("/*/") {

      local function find_file {
        parameter name, path.
        local dir is false.
        if exists(path) {
          if exists(path:combine(_name)) {
            return path:combine(_name).
          }
          set dir to open(path).
          if not dir:isfile {
            local lst is dir:list.
            for k in lst:keys {
              if not lst[k]:isfile {
                local find is find_file(name, path(k)).
                if (not find:istype("boolean")) {
                  return find.
                }
              }
            }
          }
        }
      }

      set sp to find_file(_name, path(sp:tostring:split("/*/")[0])).
      if exists(sp) {
        return sp:tostring.
      }
      // recursive search
      // find_file(_name, sp:tostring():split("/*/")[0]).
    }
  }
  return _name.
}

local function ksparse {
  local parameter s, _options is lex().
  local t is ",". local q is 0. local c is 0. local e is 0.
  local pres to "~/!pres"+"erve*/".
  set pack_total_size to pack_total_size + s:length.

  if _options:haskey("defs") and (not _options["defs"]:istype("boolean") or _options["defs"]) and not _options:haskey("is_def") {
    local _temp_pack_total_size to pack_total_size. // cache total size counter

    local _def_options to option_templates["definitions"]:copy.

    if _options["defs"]:istype("boolean") and _options["defs"] = true {
      set _options["defs"] to list().
    }

    set _def_options["defs"] to _options["defs"].
    set _def_options["is_def"] to true.
    set _def_options["keep_defines"] to _options["keep_defines"].

    set _def_options["library"] to _options["library"].
    set _def_options["filename"] to _options["filename"].
    set _def_options["base_filename"] to _options["base_filename"].

    set s to ksparse(s, _def_options).

    if s:istype("lexicon") return s.

    set pack_total_size to _temp_pack_total_size. // reset total size counter
  } else {
    // set s to "  " + s + "  ".
  }

  local operators is "+-*/^<>=".
  local parens is "{}()[]".
  local whitespace is " " + char(10) + char(13) + char(9).
  local operations is " declare global function parameter local log print edit set unset defined toggle on off is to list for break from step return preserve in on if else when then do until not and or run once compile lock unlock all ".

  local k is "# []{}():-+*/^=<>@,:."+char(34)+char(13)+char(10)+char(9).
  // local e is lex("\",92,char(34),34,"'",39,"r",13,"n",10).
  // for t in e:keys set s to s:replace("\"+t,"\!*\"+e[t]).
  for t in k set s to s:replace(t,"\!"+"#\"+t).
  // for t in e:keys set s to s:replace("\!*\"+e[t],char(e[t])).
  local t is "".
  local x to list().
  for s in s:split("\!"+"#\") {
    if s:length > 0 {
      if q {
        if s[0]=q or q = "/" {
          // print ">(" + q + ")" + s.
          if q = "/" and s[0] <> "/" {
            x:add(t).
            x:add(s).
            // print "  abort (" + t + ")(" + s +")".
            toggle q.
          } else if q = "/" or q = "#" {
            set t to t + s.
            set q to char(10).
          } else if q = char(10) {
            toggle q.
            x:add(t + char(10)).
            // print ">" + t.
            x:add(s:remove(0,1)).
          } else {
            // print "END>"+ t + q.
            x:add(t + q).
            x:add(s:remove(0,1)).
            toggle q.
          }
        }
        else set t to t+s.
      } else {
        set t to s.
        set k to s[0].
        if char(34)=k {
          set q to k.
        } else if "/"=k {
          set q to "/".
          if(s:length > 1 and s[1] = "/") {
            set q to char(10).
          }
        } else if "#"=k {
          set q to char(10).
        }
        else {
          x:add(t).
        }
      }
    }
  }


  local cs to "abcdefghijklmnopqrstuvwxyz_0123456789".
  local is_declare to false.
  local is_params to false.
  local s to "".

  local reps to "abcdefghijklmnopqrstuvwxyz":split("").
  reps:REMOVE(0).
  reps:REMOVE(reps:length - 1).

  local flag_lazy to false.
  local is_lazy to true.

  local level to 0.
  local replacements to lex().
  local param_level to 0.
  if _options["minimize_locals"] or _options:haskey("is_embed") {
    // this code mainly handles minimizing local names, but is also
    // important for ensuring emedded root functions are global

    local idx to 0.
    for _tok_trim in x {
      if (_tok_trim="@LAZYGLOBAL") {
        set flag_lazy to true.
      }
      if (flag_lazy) {
        if _tok_trim = "off" {
          set is_lazy to false.
        }
        if _tok_trim = "." {
          set flag_lazy to false.
        }
      }

      if _tok_trim:trim:startswith("{") {
        set level to level + 1.
      }
      if _tok_trim:trim:startswith("(") {
        set level to level + 1.
      }
      if _tok_trim:trim:startswith("[") {
        set level to level + 1.
      }
      if _tok_trim:trim:startswith("}") {
        set level to level - 1.
      }
      if _tok_trim:trim:startswith(")") {
        set level to level - 1.
      }
      if _tok_trim:trim:startswith("]") {
        set level to level - 1.
      }

      // TODO use scope stack for local replacement
      if is_declare and _tok_trim:trim() and not operations:contains(" " + _tok_trim:trim + " ") and cs:contains(_tok_trim:trim[0]) {
        if is_declare="global" {
          if (_options["verbose"]) {
            print _tok_trim:trim + " => " + _tok_trim:trim.
          }
        } else {
          if _options["minimize_locals"] and not replacements:haskey(_tok_trim:trim) {
            if _options["minimize_locals"]:typename = "scalar" {
              local ct to "".
              until
                not replacements:hasvalue(_tok_trim:trim:substring(0,Min(_tok_trim:trim:length,_options["minimize_locals"])) + ct) and
                  not check_defined(_tok_trim:trim:substring(0,Min(_tok_trim:trim:length,_options["minimize_locals"])) + ct) {
                if ct = "" {
                  set ct to 0.
                }
                set ct to ct + 1.
              }
              replacements:add(_tok_trim:trim, _tok_trim:trim:substring(0,Min(_tok_trim:trim:length,_options["minimize_locals"])) + ct).
            } else {
              if (reps:length > 0) {
                replacements:add(_tok_trim:trim, reps[0]).
                reps:REMOVE(0).
              } else {

                local ct to "".
                until
                  not replacements:hasvalue(_tok_trim:trim:substring(0,Min(_tok_trim:trim:length,1)) + ct) and
                    not check_defined(_tok_trim:trim:substring(0,Min(_tok_trim:trim:length,1)) + ct) {
                  if ct = "" {
                    set ct to 0.
                  }
                  set ct to ct + 1.
                }
                replacements:add(_tok_trim:trim, _tok_trim:trim:substring(0,Min(_tok_trim:trim:length,1)) + ct).
              }
            }
          }
          if _options["minimize_locals"] and _options["verbose"] {
            print _tok_trim:trim + " => " + replacements[_tok_trim:trim].
          }
          is_declare off.
        }
      }
      if _tok_trim:trim = "function" {
        if is_declare <> "global" and is_declare <> "local" {
          // ensure embedded root functions are global, is_lazy?
          if _options:haskey("is_embed") and level = 0 {
            set x[idx] to _tok_trim:replace("function", "global function").
            set is_declare to "global".
          } else {
            set is_declare to "function".
          }
        }
      }
      // if _tok_trim:trim = "set" {
      //   TODO make sets global for embeds when lazy globals are different
      //   if is_lazy and level = 0 {
      //     set x[idx] to _tok_trim:replace("set", "global").
      //     set is_declare to "global".
      //   }
      // }
      if _tok_trim:trim = "for" {
        set is_declare to "for".
      }
      if _tok_trim:trim = "parameter" {
        set is_declare to "parameter".
        is_params on.
        set param_level to level.
      }
      if _tok_trim:replace("}",""):trim = "local" {
        set is_declare to "local".
      }
      if _tok_trim:trim = "declare" {
        set is_declare to "declare".
      }
      if _tok_trim:replace("}",""):trim = "global" {
        set is_declare to "global".
      }
      if _tok_trim:trim:startswith(",") and is_params and param_level = level {
        set is_declare to "parameter".
        // print "param" + _tok_trim.
      }
      if _tok_trim:trim = "." {
        if is_params and param_level < level {
        } else {
          // print param_level + " / " + level.
          is_params off.
        }
        is_declare off.
      }
      set idx to idx + 1.
    }
  }

  local flag_lazy to false.
  local flag_parameter to false.
  local flag_once to false.
  local flag_once_args to false.
  local is_lazy to true.
  local first_statement to true.

  local lineNr to 0.
  local colNr to 0.
  local sep to char(10).
  if _options:haskey("multiline") and not _options["multiline"] {
    set sep to " ".
  }
  local def_stk is stack().
  local idx to 0.
  for _tok_trim in x {
    if _tok_trim:contains(char(10)) {
      set lineNr to lineNr + 1.
    }
    local _tok_orig to _tok_trim.
    set _tok_trim to _tok_trim:trim.
    if replacements:haskey(_tok_trim) {
      set _tok_orig to _tok_orig:replace(_tok_trim, replacements[_tok_trim]).
      set _tok_trim to replacements[_tok_trim].
    }
    if _tok_trim:length > 1 and _tok_trim[0] <> ":" {
      if not cs:contains(_tok_trim[0]) and replacements:haskey(_tok_trim:remove(0,1):trim) {
        set _tok_orig to _tok_orig:replace(_tok_trim, _tok_trim[0] + replacements[_tok_trim:remove(0,1):trim]).
        set _tok_trim to _tok_trim[0] + replacements[_tok_trim:remove(0,1):trim].
      }
      if not cs:contains(_tok_trim[_tok_trim:length-1]) and replacements:haskey(_tok_trim:substring(1,_tok_trim:length-1):trim) {
        set _tok_orig to _tok_orig:replace(_tok_trim, replacements[_tok_trim:substring(1,_tok_trim:length-1):trim] + _tok_trim[_tok_trim:length-1]).
        set _tok_trim to replacements[_tok_trim:substring(1,_tok_trim:length-1):trim] + _tok_trim[_tok_trim:length-1].
      }
    }
    if true { // _tok_trim <> "" {
      if (_tok_trim="@LAZYGLOBAL") {
        set flag_lazy to true.
      }

      if not _options:haskey("minimize") or _options["minimize"] {
        if (_tok_trim="lexicon") {
          set _tok_trim to "lex".
          set _tok_orig to _tok_orig:replace("lexicon", "lex").
        }
        if (_tok_trim="declare") {
          set _tok_trim to "".
          set _tok_orig to _tok_orig:replace("declare", "").
        }
      }

      if (_tok_trim="parameter" and first_statement and _options:haskey("is_embed")) {
        set flag_parameter to true.
      }
      if _tok_trim = "." or _tok_trim = "{" {
        set first_statement to false.
      }
      if (_tok_trim = "run" or _tok_trim = "runoncepath") and _options:haskey("embed") and _options["embed"] {
        set flag_once to true.
      }
      if (_tok_trim = "." and flag_parameter) {
        local s2 to s.
        if _options:haskey("comments") and _options["comments"]
          set s to "// parameter" + s:split("parameter")[1] + char(10).
        else
          set s to "". // TODO check if this works?
        local ix to 0.
        for p in s2:split("parameter")[1]:split(",") {
          if _options:haskey("args") and ix < _options["args"]:length {
            local pname to p:trim:split(" ")[0].
            set s to s +  "local " + pname + " to " + _options["args"][ix] + "." + sep.
          } else {
            if p:trim:split(" ")[1] = "" {
              set s to s +  "local " + p:trim + " to false." + sep. // not to spec, but useful?
            } else {
              set s to s +  "local " + p:trim + "." + sep.
            }
          }
          set ix to ix + 1.
        }
        set flag_parameter to false.
      } else if (flag_once) {
        if flag_once = true {
          set flag_once_args to list("").
          set flag_once to "".
          if _options:haskey("minimize") and not _options["minimize"] {
            set s to s + _tok_orig:split(_tok_trim)[0] + pres.
          }
        }
        if _tok_trim = "," {
          flag_once_args:add("").
        } else if flag_once <> "" {
          if not ".(),":contains(_tok_trim) and _tok_trim <> "once" {
            set flag_once_args[flag_once_args:length-1] to flag_once_args[flag_once_args:length-1] + _tok_orig.
          }
        }
        set flag_once to flag_once + _tok_orig.
        if _tok_trim = "." {

          local peek_id to idx.
          until peek_id >= x:length - 2 {
            set peek_id to peek_id + 1.
            if (x[peek_id]:trim <> "") {
              break.
            }
          }

          local embed_markup to "".
          if (x[peek_id]:startswith("//")) {
            set embed_markup to x[peek_id]:remove(0,2):trim.
          }

          local _fn to flag_once_args[0]:trim:replace(char(34), "").
          local _name to _fn:split("/")[_fn:split("/"):length-1]:replace(".ksm",""):replace(".ks","").
          if not pack_run_once_list:contains(_name) {
            pack_run_once_list:add(_name).
            // find library
            set _fn to find_library(_fn, _options).
            // print "FOUND: " + _fn.
            if not embed_markup:contains("ignore") and exists(_fn) {
              set _s to open(_fn):readall():string.
            } else {
              set _s to false.
            }
          } else {
            set _s to "".
          }

          if _s {
            if (flag_once_args[0]:contains(_fn)) {
              print "embbedding: " + "@ <= " + _fn.
            } else {
              print "embbedding: " + flag_once_args[0]:replace(char(34),"") + " <= " + _fn.
            }
          } else if _s <> false and _options["verbose"] {
            print "embedded:   " + flag_once_args[0]:replace(char(34),"").
          } else {
            if embed_markup:contains("ignore") {
              if _options["verbose"] {
                print "ignoring:   " + flag_once_args[0]:replace(char(34),"").
              }
            } else {
              print "skipping:   " + flag_once_args[0]:replace(char(34),"").
            }
          }
          if _s <> false {

            local _embed_options to _options:copy.
            set _embed_options["is_embed"] to true.
            set _embed_options["filename"] to _fn.

            if _options["embed"] {
                set _embed_options["multiline"] to false.
                set _embed_options["comments"] to false.
                set _embed_options["minimize"] to true.
                if not _options:haskey("minimize_locals") or not _options["minimize_locals"]
                  set _embed_options["minimize_locals"] to true.

                if embed_markup:contains("expand") or _options["embed"] = "expand" {
                  set _embed_options["multiline"] to true.
                  set _embed_options["comments"] to true.
                  set _embed_options["minimize"] to false.
                  set _embed_options["minimize_locals"] to false.
                }

                if embed_markup:contains("inline") {
                    set _embed_options["multiline"] to false.
                    set _embed_options["comments"] to false.
                    set _embed_options["minimize"] to true.
                    if not _options:haskey("minimize_locals") or not _options["minimize_locals"]
                      set _embed_options["minimize_locals"] to true.
                }

                if (" "+embed_markup+" "):contains(" minimize ") {
                  set _embed_options["minimize"] to true.
                }
                if (" "+embed_markup+" "):contains(" no_minimize ") {
                  set _embed_options["minimize"] to false.
                }
                if embed_markup:contains("minimize_locals") {
                  set _embed_options["minimize_locals"] to true.
                }
                if embed_markup:contains("no_minimize_locals") {
                  set _embed_options["minimize_locals"] to false.
                }
                if embed_markup:contains("multiline") {
                  set _embed_options["multiline"] to true.
                }
                if embed_markup:contains("comments") {
                  set _embed_options["comments"] to true.
                }
            }

            set _embed_options["args"] to flag_once_args:sublist(1, flag_once_args:length - 1).
            local comment to "// " + flag_once:replace(char(10)," "):trim + char(10) + pres. // runoncepath(" + flag_once_args[0] + ")." + char(10) + pres.

            if _options:haskey("comments") and _options["comments"] {
              if _options["embed"] = "inline" {
                set comment to char(34) + "runoncepath(" + flag_once_args[0]:replace(char(34),"") + ")" + char(34) + ".".
              }
            } else {
              set comment to "".
            }
            if _s {
              set s to s:trim + comment + "{" + ksparse(_s, _embed_options).
              if _embed_options["minimize"] {
                until not s:trim:endswith(pres) {
                  set s to s:trim:remove(s:trim:length-pres:length, pres:length):trim.
                }
              }
              set s to s + "}".
            } else {
              set s to s:trim + comment.
            }
          } else {
            if _options:haskey("minimize") and _options["minimize"] {
              set s to s:trim + flag_once:trim + sep.
            } else {
              set s to s:trim + (flag_once + pres):trim.
            }
          }
          set flag_once to false.
        }
      } else if (flag_lazy and (not (_options:haskey("minimize") and _options["minimize"] = false) or _options:haskey("is_embed"))) {
        if flag_lazy = true {
          set flag_lazy to "".
        }
        set flag_lazy to flag_lazy + _tok_orig.
        if _tok_trim = "off" {
          set is_lazy to false.
        }
        if _tok_trim = "." {
          set first_statement to false. // not necessary since parameter and lazyglobal cant exist at head of same file?
          if _options:haskey("is_embed") and _options["is_embed"] {
              if (_options:haskey("minimize") and _options["minimize"] = false)
                set s to s + "// " + flag_lazy + pres.
              else if (_options:haskey("comments") and _options["comments"])
                set s to s:trim + "// " + flag_lazy + char(10) + pres.
          } else {
            set s to s:trim + flag_lazy + char(10) + pres.
          }
          set flag_lazy to false.
        }
      } else if _options:haskey("minimize") and _options["minimize"] = false {

        local pad to 0.
        local ct to 0.

        local function _keep_defines {
          local parameter s, _tok_orig, pad, _options, mode is false.
          if s:endswith(" ") and _tok_orig and _tok_orig[0] = " " {
            // print _tok_orig.
          }
          if _options["keep_defines"] {

            local i is 1.
            until x[idx+i] <> " " or i >= x:length - 1
              set i to i + 1.
            local nt to x[idx + i].

            if mode {
              if not s:endswith(char(10)) {
                return s + _tok_orig.
              } else {
                if _tok_orig:length > 1 and _tok_orig:startswith(char(10)) {
                  return s + "//#" + char(10) + "//# " + _tok_orig:remove(0, 1).
                } else if not nt:replace(" ",""):startswith("//#") and not nt:replace(" ",""):startswith("///#") and not nt:replace(" ",""):startswith("////#")
                and not _tok_orig:replace(" ",""):startswith("//#") and not _tok_orig:replace(" ",""):startswith("///#") and not _tok_orig:replace(" ",""):startswith("////#") {
                  if _tok_orig:startswith(char(10)) {
                    return s + "//#" + _tok_orig.
                    // if _tok_orig:length > 1 {
                    return s + "//# " + _tok_orig:remove(0, 1).
                    // }
                  } else {
                    return s + "//# " + _tok_orig.
                  }
                }
              }
            }
            if _tok_orig:startswith("//#") and s:endswith("//#") {
              return s:remove(s:length-3,3) + "":padright(pad) + _tok_orig.
            }
            if _tok_orig:replace(" ",""):startswith("//#") and s:endswith("//#") {
              return s:remove(s:length-3,3) + "":padright(pad) + _tok_orig.
            }
            if _tok_orig:startswith("//#") {
              if s:endswith("//#") and _tok_orig:replace(" ",""):startswith("//#") {
                set s to s:remove(s:length-3,3) + "":padright(pad) + _tok_orig.
              } else  {
                set s to s + "":padright(pad) +  _tok_orig.
              }
            } else if s:endswith("//#") and _tok_orig:startswith("#") {
              set s to s:remove(s:length-1,1) + "":padright(pad) + _tok_orig.
            } else if s:replace(" ", ""):endswith("//") and _tok_orig:startswith("#") {
              set s to s + "":padright(pad) + _tok_orig.
            } else if s:replace(" ", ""):trim:endswith("//") {
              set s to s + "":padright(pad) + _tok_orig.
            } else if _tok_orig:startswith("//") {
                set s to s + "":padright(pad) + _tok_orig.
            } else {
              if nt:replace(" ",""):startswith("//#") or nt:replace(" ",""):startswith("///#") or nt:replace(" ",""):startswith("////#") {
                set s to s + "":padright(pad) + _tok_orig.
              } else {
                set s to s + "//" + "":padright(pad) + _tok_orig.
              }
            }
          } else if not s:endswith(char(10)) {
            if _tok_orig:replace(" "):startswith("///#") or _tok_orig:replace(" "):startswith("////#") {
              return s.
            }
            set s to s + char(10) + " ". // TODO adding a space, this cant be right?
          }
          return s.
        }

        if (_tok_trim:startswith("#") or _tok_trim:startswith("//")) and not _options:haskey("is_def") and _options:haskey("comments") and _options["comments"] = false {
          // skip comments
          until not s:endswith(" ") {
            set pad to pad + 1.
            set s to s:remove(s:length-1, 1).
          }
        } else if _options:haskey("is_def") and (_tok_trim:startswith("//") or _tok_trim:startswith("#")) {
          if _tok_trim:startswith("#") or _tok_trim:remove(0,2):trim:startswith("#") {

            if def_stk:length = 0 or not def_stk:peek[0] {
              until not s:endswith(" ") {
                set pad to pad + 1.
                set s to s:remove(s:length-1, 1).
              }
            }

            // process directives
            local def_dir is _tok_trim.
            if def_dir:startswith("//") {
              set def_dir to def_dir:remove(0,2):trim.
            }

            local prev_val to (def_stk:length = 0 or def_stk:peek()[0]).

            if (def_dir:startswith("#if")) {
              until not s:endswith(" ") {
                set pad to pad + 1.
                set s to s:remove(s:length-1, 1).
              }
              local def_logic to def_dir:split(" ")[0]:trim.
              local def_var to def_dir:split(" ")[1]:trim:split(" ")[0].
              local def_val to _options["defs"]:contains(def_var) or _options["defs"]:contains("@" + def_var).

              // if logic is positive #ifdef, or negative #ifndef
              set def_logic to (def_logic = "#ifdef").
              // if def matches logic
              set def_val to def_val = def_logic.
              def_stk:push(list((def_val and prev_val), def_var, def_val)).

              set s to _keep_defines(s, _tok_orig, pad, _options).
            } else if (def_dir:startswith("#endif")) {

              until not s:endswith(" ") {
                set pad to pad + 1.
                set s to s:remove(s:length-1, 1).
              }
              if (def_stk:length > 0) def_stk:pop().

              set s to _keep_defines(s, _tok_orig, pad, _options).
            } else if (def_dir:startswith("#else")) {
              until not s:endswith(" ") {
                set pad to pad + 1.
                set s to s:remove(s:length-1, 1).
              }
              // flip current #if value
              local p to def_stk:pop().
              set p[2] to not p[2].
              // check parent #if
              if def_stk:length = 0 or def_stk:peek()[0] {
                set p[0] to p[2].
              }
              // replace current stack
              def_stk:push(p).
              set s to _keep_defines(s, _tok_orig, pad, _options).
            } else if (def_stk:length = 0 or def_stk:peek()[0])
                      and (def_dir:startswith("#pack") or def_dir:startswith("#warning") or def_dir:startswith("#error")) {
              if (def_dir:startswith("#error")) {

                local function buildContext {
                  local parameter tokens, index, before, after, length is terminal:width.
                  return "".
                }
                // print def_dir.
                return lex(
                  "error_type", "Directive",
                  "error", def_dir:remove(0,6):trim:replace(char(34), ""),
                  "filename", _options["filename"],
                  "line", lineNr,
                  "col", colNr,
                  "context", def_dir // buildContext(x, idx, 5, 5).
                ).
              } else {
                print def_dir.
              }
              until not s:endswith(" ") {
                set pad to pad + 1.
                set s to s:remove(s:length-1, 1).
              }
              set s to _keep_defines(s, _tok_orig, pad, _options).
            } else {
              if (def_stk:length = 0 or def_stk:peek()[0])
                 and (def_dir:startswith("#define") or def_dir:startswith("#undef")) {
                until not s:endswith(" ") {
                  set pad to pad + 1.
                  set s to s:remove(s:length-1, 1).
                }
                local def_state to true.
                for d in def_dir:split(" ") {
                  if d:trim {
                    if d:trim = "#define" {
                      def_state on.
                    } else if d:trim = "#undef" or d:trim = "#undefine" {
                      def_state off.
                    } else if def_state {
                      if not _options["defs"]:contains("@" + d:trim:replace("@", "")) {
                        _options["defs"]:add("@" + d:trim:replace("@", "")).
                        print "#define " + "@" + d:trim:replace("@", "").
                      }
                    } else {
                      if _options["defs"]:contains("@" + d:trim:replace("@", "")) {
                        for i in range(_options["defs"]:length - 1, -1) {
                          if _options["defs"][i] = "@" + d:trim:replace("@", "") {
                            _options["defs"]:remove(i).
                            print "#undef " + "@" + d:trim:replace("@", "").
                          }
                        }
                      }
                    }
                  }
                }

                set s to _keep_defines(s, _tok_orig, pad, _options).
              }
              else if (def_stk:length = 0 or def_stk:peek[0]) and
                 (def_dir:startswith("#include") or def_dir:startswith("#require")) {
                until not s:endswith(" ") {
                  set s to s:remove(s:length-1, 1).
                }
                local _fn to def_dir:split(" ")[1]:replace(char(34), ""):trim.
                // TODO smarter file path parsing to support paths with spaces

                if (def_dir:startswith("#require")) {
                  // TODO only include once, add to defs / embeds?
                }

                set s to _keep_defines(s, _tok_orig, pad, _options).

                // find library
                local _include_options to _options:copy.
                set _fn to find_library(_fn, _include_options).
                if exists(_fn) {
                  print "including: " + _fn.
                  set _include_options["filename"] to _fn.
                  set s to s + ksparse(open(_fn):readall():string, _include_options).
                } else {
                  print "skipping:  " + _fn.
                }
              } else if (def_stk:length > 0 and def_stk:peek[0]) {
                set _tok_orig to _tok_orig:replace("//# ",""):replace("//#","").
                if not _tok_orig:trim {
                  until not s:endswith(" ") {
                    set pad to pad + 1.
                    set s to s:remove(s:length-1, 1).
                  }
                }
                set s to s + _tok_orig.
              } else {
                set s to _keep_defines(s, _tok_orig, pad, _options).
              }
            }
          } else if (def_stk:length = 0 or def_stk:peek()[0]) and not _tok_orig:replace(" ",""):startswith("///") {
            set s to s + _tok_orig.
          } else {
            set s to _keep_defines(s, _tok_orig, pad, _options, true).
          }
          // end process directives
        } else if (def_stk:length = 0 or def_stk:peek()[0]) {
          set s to s + _tok_orig.
        } else {
          if _tok_orig <> "" {
            if _tok_orig <> " " or not (_tok_orig:replace(" ", ""):startswith("//#")) {
              // HACK more crazy stuff to make definition comments line up properly
              set s to _keep_defines(s, _tok_orig, pad, _options, true).
            }
          }
        }
      } else if (def_stk:length > 0 and not def_stk:peek()[0]) {

        // if _options["keep_defines"] { // FIXME Unreachable?
        //   print ">" + _tok_orig.
        //   set s to s + "//#" + _tok_orig.
        // }
        // print "#IF SKIPPING NOT DEFINED".
      } else if (_tok_trim:startswith("//")) {
        if _options:haskey("comments") and _options["comments"]
          set s to s:trim + _tok_trim + char(10) + pres.
      } else if _tok_trim and "{}()":contains(_tok_trim[0]) {
        if _options["minimize"] and not _options["comments"] {
          until not s:trim:endswith(pres) {
            set s to s:trim:remove(s:trim:length-pres:length, pres:length):trim.
          }
        }
        set s to s:trim+_tok_trim.
      }
      else if (_tok_trim = ".") {
        if _options["minimize"] and ("@)]"+char(34)):contains(s:trim[s:trim:length-1]) {
          // if we are not following a possible bare word, we don't need a separator
          set s to s+_tok_trim.
        } else {
          set s to s+_tok_trim+sep+pres.
        }
      } else if (s and cs:contains(s[s:length-1])) and (_tok_trim and cs:contains(_tok_trim[0])) {

        // make a newline after 80 characters
        if _options["minimize"] and _options["multiline"] and s:length > 70 {
          if not s:substring(s:length-70,70):contains(char(10)) {
            set s to s+char(10)+_tok_trim.
            set _tok_trim to "".
          }
        }
        if _tok_trim <> "" {
          set s to s+" "+_tok_trim.
        }
      } else {
        if _options:haskey("is_embed") and _options["embed"] = "inline" and _tok_trim and _tok_trim[0] = char(34) {
          // handle multiline strings in inlne embed mode
          set _tok_trim to _tok_trim:replace(char(10), char(34) + "+char(10)+" + char(34)).
        }
        set s to s+""+_tok_trim.
      }
    }
    set idx to idx + 1.
  }
  // set pres to pres:replace("~","").
  return s:replace(pres,"").
}
