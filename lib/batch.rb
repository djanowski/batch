class Batch
  VERSION = "0.0.3"

  attr :enumerable

  def initialize(enumerable)
    @enumerable = enumerable
    @width = (ENV["BATCH_WIDTH"] || 75).to_i
    @size = enumerable.size if enumerable.respond_to?(:size)
  end

  def each(&block)
    @errors = []
    @current = 0

    report_progress

    enumerable.each do |item|
      begin
        yield(item)
        print "."

      rescue Interrupt => e
        raise e

      rescue Exception => e
        print "E"
        @errors << [item, e]

      ensure
        @current += 1

        if eol?
          print "\n"
          report_progress
        end
      end
    end

    print "\n"
    puts "100% " unless eol?

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
    @size
  end

  def progress
    return unless @size

    @current * 100 / @size
  end

  def report_progress
    if progress
      print "#{progress.to_s.rjust 3, " "}% "
    else
      print "   ? "
    end
  end

  def eol?
    @current % @width == 0
  end

  def self.each(enumerable, &block)
    new(enumerable).each(&block)
  end

  def self.start(title, enumerable, &block)
    puts
    puts(title)
    puts
    each(enumerable, &block)
  end
end
