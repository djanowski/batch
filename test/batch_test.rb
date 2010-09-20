# encoding: UTF-8

require File.expand_path("./test_helper", File.dirname(__FILE__))

class BatchTest < Test::Unit::TestCase
  should "report" do
    stdout, _ = capture do
      Batch.each((1..80).to_a) do |item|
        item + 1
      end
    end

    expected = <<-EOS
  0% ...........................................................................
 93% .....
100%
EOS

    assert_equal expected.rstrip, stdout.rstrip
  end

  should "not halt on errors" do
    stdout, stderr = capture do
      Batch.each((1..80).to_a) do |item|
        raise ArgumentError, "Oops" if item == 3
      end
    end

    expected_stdout = <<-EOS
  0% ..E........................................................................
 93% .....
100%
EOS

    expected_stderr = <<-EOS

Some errors occured:

3: Oops
EOS

    assert_equal expected_stdout.rstrip, stdout.rstrip
    assert_equal expected_stderr.rstrip, stderr.rstrip
  end

  should "use BATCH_WIDTH" do
    ENV["BATCH_WIDTH"] = "40"
    stdout, _ = capture do
      Batch.each((1..80).to_a) do |item|
        item + 1
      end
    end

    expected = <<-EOS
  0% ........................................
 50% ........................................
100%
EOS

    assert_equal expected.rstrip, stdout.rstrip
  end
end
