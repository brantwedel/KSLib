
// Note: This requires KSpec - see https://github.com/gisikw/kspec

RUN lib_pack.

function _replace_quotes { parameter s. return s:replace("'",char(34)). }

describe("lib_pack").
  it("exposes a global pack module", "test_module").
    function test_module {
      Pack. assert(true).
    }
  end.

  it("has a version property equal to 0.1.0", "test_version").
    function test_version {
      assert_equal(Pack["version"], "0.1.0").
    }
  end.

  describe("pack").
    context("when run with minify option").
      it("returns a minified file", "test_minify").
        function test_minify {
          local _fn is "1:/_pack_minify_test.ks".
          deletepath(_fn).
          create(_fn):write(_replace_quotes(
"
run file.ks.
global long_global is '5'.
local long_local is 5.
print'TEST'.
if long_global = long_local
  print 'fine'.
// goodbye comment
local function some_long_local_function {
  local parameter
    long_param_name,
    another_long_param_name is '_default'.
  print 'super fine' + long_param_name.
  print 'extra fine' + another_long_param_name.
}
some_long_local_function(). // goodbye comment
"
)).
          assert_equal(Pack["minify"]("1:/_pack_minify_test.ks")["packed"], _replace_quotes(
"run file.ks.
global long_global is'5'.local a is 5.
print'TEST'.if long_global=a print'fine'.local function b{local
parameter c,d is'_default'.print'super fine'+c.
print'extra fine'+d.}b()."
          )).
        }
      end.
    end.
  end.

end.
