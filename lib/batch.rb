class Batch
  VERSION = "1.0.3"

  attr :enumerable

  def initialize(enumerable)
    @enumerable = enumerable
    @width = (ENV["BATCH_WIDTH"] || 75).to_i
    @size = enumerable.size if enumerable.respond_to?(:size)
  end

  def each(&block)
    @errors = []
    @current = 0

    Batch.out do |io|
      enumerable.each.with_index do |item, index|
        report_progress(io) if index == 0

        begin
          yield(item)
          io.print "."

        rescue Interrupt => e
          report_errors
          raise e

        rescue Exception => e
          raise e if $DEBUG
          io.print "E"
          @errors << [item, e]

        ensure
          @current += 1

          if eol?
            io.print "\n"
            report_progress(io)
          end
        end
      end

      if @current > 0
        io.print "\n"
        io.puts "100% " unless eol?

        report_errors
      end
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

  def report_progress(io)
    if progress
      io.print "#{progress.to_s.rjust 3, " "}% "
    else
      io.print "   ? "
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

    out do |io|
      io.puts
      io.puts(title)
      io.puts
    end

    each(enumerable, &block)
  end

  def self.out(&block)
    interactive? ? yield($stdout) : File.open("/dev/null", "w", &block)
  end

  def self.interactive?
    (ENV["BATCH_INTERACTIVE"] || 1).to_i == 1
  end
end
