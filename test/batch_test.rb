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
    stdout, _ = with_env("BATCH_WIDTH" => "40") do
      capture do
        Batch.each((1..80).to_a) do |item|
          item + 1
        end
      end
    end

    expected = <<-EOS
  0% ........................................
 50% ........................................
100%
EOS

    assert_equal expected.rstrip, stdout.rstrip
  end

  should "print a title" do
    stdout, _ = capture do
      Batch.start("Printing numbers", [1]) do |item|
      end
    end

    expected = <<-EOS

Printing numbers

  0% .
100%
EOS

    assert_equal expected.rstrip, stdout.rstrip
  end

  should "work with unknown sizes" do
    stdout, _ = capture do
      Batch.each(1..80) { }
    end

    expected = <<-EOS
   ? ...........................................................................
   ? .....
100%
EOS

    assert_equal expected.rstrip, stdout.rstrip
  end

  should "not print anything when there's nothing to do" do
    stdout, stderr = capture do
      Batch.each([]) { }
    end

    assert_empty stdout.rstrip
    assert_empty stderr.rstrip

    stdout, stderr = capture do
      Batch.start("Not much work", []) { }
    end

    assert_empty stdout.rstrip
    assert_empty stderr.rstrip
  end

  should "be silent when BATCH_INTERACTIVE is 0" do
    stdout, stderr = with_env("BATCH_INTERACTIVE" => "0") do
      capture do
        Batch.each((1..80).to_a) do |item|
          item + 1
        end
      end
    end

    assert_empty stdout.rstrip
    assert_empty stderr.rstrip

    stdout, stderr = with_env("BATCH_INTERACTIVE" => "0") do
      capture do
        Batch.start("Silent actually", (1..80).to_a) do |item|
          item + 1
        end
      end
    end

    assert_empty stdout.rstrip
    assert_empty stderr.rstrip
  end

  def with_env(env)
    old = {}

    begin
      env.each do |key, value|
        old[key] = ENV[key]
        ENV[key] = value
      end

      yield
    ensure
      old.each do |key, value|
        ENV[key] = value
      end
    end
  end
end
