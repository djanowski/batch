class Batch
  VERSION = "0.0.3"

  attr :enumerable

  def initialize(enumerable)
    @enumerable = enumerable
    @width = (ENV["BATCH_WIDTH"] || 75).to_i
  end

  def each(&block)
    @errors = []
    @current = 0

    print "  0% "

    enumerable.each do |item|
      begin
        yield(item)
        print "."

      rescue Interrupt
        break

      rescue Exception => e
        print "E"
        @errors << [item, e]

      ensure
        @current += 1

        report_progress if eol?
      end
    end

    print "\n"

    report_errors

    nil
  end

  def report_errors
    return if @errors.empty?

    $stderr.puts "\nSome errors occured:\n\n"

    @errors.each do |item, error|
      report_error(item, error)
    end
  end

  def report_error(item, error)
    $stderr.puts "#{item.inspect}: #{error}\n"
  end

  def total
    @enumerable.size
  end

  def progress
    @current * 100 / total
  end

  def report_progress
    print "\n#{progress.to_s.rjust 3, " "}% "
  end

  def eol?
    @current % @width == 0 || @current == total
  end

  def self.each(enumerable, &block)
    new(enumerable).each(&block)
  end
end
