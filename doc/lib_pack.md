
# Lib_Pack

> Lib_Pack v0.1.0  
>Script packager and minifier with preprocessor support  
> Originally developed by brantwedel

This library is a code minifier and library packager, it does static analysis on ks files to embed dependencies and provide optimal compression.

## pack

Arguments unordered, by type:
  * a filename or Path() - the path of the file to pack.
  * a template name `"default"` - template for packing: "default", "minify", "expand", "directives"
  * directive defines `"@some_lib_option @some_lib_other_option"` - defined symbols for directives (@see directives section)
  * a lexicon of options `lexicon()` - granular packing and minification options:
    * minimize=`false` - Produce the smallest code by removing unnecessary whitespace
    * comments=`true` - weather to include or strip comments
    * embed=`false` - embed dependencies
      * `true` - dependencies embedding use the template packing/minification options
      * template name - `embed, expand, minify, etc.` use a template for packing embeds
      * **TODO** `lex()` - recursive embde options, same as pack options lexicon
      * **TODO** `list()` - recursive embed options, same as pack options arguments
    * multiline=`true` - use lines or spaces for whitespace
                         Note: (spaces are more efficient than lines when
                         compiling ksm files as the per-line debugging
                         information will not be included -- produces same size ks files)
    * minimize_locals=`false` - if true or a number, local variable/function names will be shortened to save space
    * **TODO** library_paths=`list("0:/library/*")` - global library paths, end with `*` for recursive search (@see library_order)
    * **TODO** library_order=`list("absolute","local","library")` - change the library search order precedence
    * **TODO** deploy=`false` - output/dependencies to path or a ship name running the bootloader
    * **TODO** bootloader=`false` - include small bootloader for remote deploys
    * defs=`list()` - define sections of code to include using definitions (@see directives section)
    * ipu=`5000` - temporarily adjust (overclock) `instructions per update` during packing for better performance.

description:
  * transforms a ks file into packed and compiled versions with the extensions `*.pak.ks` and `*.pak.ksm`, optionally minifying, preprocessing, and embedding dependencies.

example:

  ```ks
  // use in interpreter with run
  run "lib_pack.ks"("some-file.ks", "minify").
  ```

  ```ks
  // use Pack module in some kind of build file
  run once "lib_pack.ks".
  Pack["pack"]("some-file.ks", "minify").
  Pack["pack"]("some-other-file.ks", lex("minimize", false, "comments", false, "minimize_locals", true)).
  ```

## directives

Dependency directive comments following a run/runpath statement:

* `run "some-file.ks".` - any run statement without a directive will use the default pack options.
* `run "some-file.ks". //#inline` - embed the contents of the run statement into a single line so as not to change debugging line numbers.
* `run "some-file.ks". //#expand` - embed the contents of the run statement expanded, to help with debugging.
* `run "some-file.ks". //#ignore` - leave the run statement as is.
* **TODO** `run "some-file.ks". //#options "default"` - an options template name to use (same options as pack)
* **TODO** `run "some-file.ks". //#options "default" lex("library", "0:/some-library/")` - a lexicon to override specific options (same options as pack)
* **TODO** `run "0:/lib/some-file.ks". //#options "copy"` - packs and copies the source file to output using the template/options, and modifies the statement to be a relative path.
* **TODO**`run "0:/lib/some-file.ks". //#pack("some-shared-file.ks")` - packs and concatenates the file with any other files using the same shared output filename, modifies the statement to "run once".

C/C++ style preprocessor directive comments:

* `//#define @symbol` - defines/enables a symbol (preferred to start with an @ to not clash with var names, but not required)
* `//#undef @symbol` - undefines/disables a symbol
* `//#ifdef @symbol` - includes code if symbol has been defined
* `//#ifndef @symbol` - includes code if symbol has **not** been defined
* `//#else` - inverse of previous #if block
* `//#endif` - the end of an #if/#else block
* `//#include "somefile.ks"` - include file, processing directives
* **TODO**`//#include "somefile.ks" #inline` - include file inline, processing directives
* **TODO**`//#require "afile.ks"` - include a file inline only once, processing directives
* `//# print("Hello!").` - a line of kerboscript within a directive that will only be processed by lib_pack

example:

  ```ks
  //#define @some_symbol
  //#ifdef @some_symbol
  //# print "For users that don't use lib_pack, you can leave lib_pack specifics in special comments." //# print "any comment starting with a # will be expanded when packed and follow the #directives".
  //# print "this is to provide basic functionality, defaults, or warnings to non lib_pack users".
      print "I'm an ordinary line kerboscript and am included if someone runs me without lib_pack.".
      print "However, when run with lib_pack, I obey the #directives".
  //# print "I've been included".
  //#else // be careful not to place a kerboscript else/if statement immediatly
  ////#   // after a # or it will be interpreted as a directive #else, etc.
  //# if false { // ^ leave a space after directive commented code
  //#  print "more codez!".
  //# }
  //# else
  //# {
  //#   print "This else is properly evaluated as kerboscript, since it's not touching".
  //# }
  //# print "goodbye".
  //#ifndef
  //#include "somefile.ks" // I'm included in-place during packing regardless of "embed" option
  ```
