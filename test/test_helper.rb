require "stringio"
require "contest"
require File.join(File.dirname(__FILE__), "..", "lib", "batch")

def capture
  stdout, $stdout = $stdout, StringIO.new
  stderr, $stderr = $stderr, StringIO.new
  yield
  [$stdout.string, $stderr.string]
ensure
  $stdout = stdout
  $stderr = stderr
end
