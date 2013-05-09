class Batch
  VERSION = "1.0.2"

  attr :enumerable

  def initialize(enumerable)
    @enumerable = enumerable
    @width = (ENV["BATCH_WIDTH"] || 75).to_i
    @size = enumerable.size if enumerable.respond_to?(:size)
  end

  def each(&block)
    @errors = []
    @current = 0

    enumerable.each.with_index do |item, index|
      report_progress if index == 0

      begin
        yield(item)
        print "."

      rescue Interrupt => e
        report_errors
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

    if @current > 0
      print "\n"
      puts "100% " unless eol?

      report_errors
    end

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
    return 0 if @size == 0

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
    begin
      enumerable.each.next
    rescue StopIteration
      return
    end

    puts
    puts(title)
    puts

    each(enumerable, &block)
  end
end
