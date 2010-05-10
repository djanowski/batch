class Batch
  VERSION = "0.0.1"

  attr :enumerable

  def initialize(enumerable)
    @enumerable = enumerable
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
      $stderr.puts "#{item.inspect}: #{error}\n"
    end
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
    @current % 75 == 0 || @current == total
  end

  def self.each(enumerable, &block)
    new(enumerable).each(&block)
  end
end
