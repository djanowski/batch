require "stringio"
require "contest"

require File.expand_path("./../lib/batch", File.dirname(__FILE__))

def capture
  stdout, $stdout = $stdout, StringIO.new
  stderr, $stderr = $stderr, StringIO.new
  yield
  [$stdout.string, $stderr.string]
ensure
  $stdout = stdout
  $stderr = stderr
end
