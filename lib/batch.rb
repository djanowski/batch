class Batch
  VERSION = "0.0.3"

  attr :enumerable
  attr :processed

  def self.options
    @options ||= {
      :status_on_interrupt => true,
      :log => nil,
      :mark_interval => 300
    }
  end

  def initialize(enumerable, options={})
    @enumerable = enumerable
    @width = (ENV["BATCH_WIDTH"] || 75).to_i
    @options = self.class.options.merge(options)
    @log = @options[:log]
  end

  def each(&block)
    @errors  = []
    @current = 0

    @start = Time.now
    last_interrupt = 0
    last_mark = Time.now

    print "  0% "
    log_start

    enumerable.each do |item|
      begin
        if (Time.now - last_mark).to_i >= @options[:mark_interval]
          last_mark = Time.now
          log_status
        end

        yield(item)
        print "."

      rescue Interrupt
        if @options[:status_on_interrupt]
          if (Time.now - last_interrupt).to_i <= 1
            break
          else
            report_interrupt_status
            last_interrupt = Time.now
          end
        else
          break
        end

      rescue Exception => e
        print "E"
        @errors << [item, e]
        log_error item, e

      ensure
        @current += 1

        report_progress if eol?
      end
    end

    log_done
    report_completed
    report_errors

    nil
  end

  def report_interrupt_status
    $stderr.print "\n"
    $stderr.puts
    $stderr.puts "     %i%% done (%i of %i)" % [ progress, @current, total ]
    $stderr.puts "     Elapsed:   %s" % [ time_format(elapsed) ]
    $stderr.puts "     Remaining: %s" % [ time_format(remaining) ]
    $stderr.puts "     Errors:    #{@errors.size}"  if @errors.any?
    $stderr.puts "     Press Ctrl+C again to abort."
    $stderr.puts
    $stderr.print "     "
  end

  def report_completed
    $stderr.print "\n\n"
    $stderr.puts "Completed."
    $stderr.puts
    $stderr.puts "     Elapsed:   %s" % [ time_format(elapsed) ]
    $stderr.puts "     Errors:    #{@errors.size}"  if @errors.any?
  end

  def log(type, message)
    return  if @log.nil?

    if @log.respond_to?(type.to_sym)
      # Logger.info "xx"
      @log.send type.to_sym, message

    elsif @log.respond_to?(:write)
      # $stderr.write
      stamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      msg   = "[%s] %5s: %s\n" % [ stamp, type.to_s.upcase, message ]
      @log.write msg
    end
  end

  def log_start
    log :info, "Started"
  end

  def log_done
    log :info, "Completed in %s" % [ time_format(elapsed) ]
    log :info, "Errors: #{@errors.size}"  if @errors.any?
  end

  def log_status
    log :info, "[status] %i%% done (%i of %i)" % [ progress, @current, total ]
    log :info, "[status] Elapsed:   %s" % [ time_format(elapsed) ]
    log :info, "[status] Remaining: %s" % [ time_format(remaining) ]
    log :info, "[status] Errors:    #{@errors.size}"  if @errors.any?
  end

  def log_error(item, err)
    log :error, "#{item}: #{err.class}: #{err.message}"
    err.backtrace.each { |line| log :error, "  #{line}" }
  end

  def time_format_segments(secs)
    hours = secs / 3600
    secs %= 3600

    mins  = secs / 60
    secs %= 60

    [ hours, mins, secs ]
  end

  def time_format(secs)
    return "Unknown"  if secs.nil?

    hours, mins, secs = time_format_segments(secs)

    words = Array.new

    words << "#{hours.to_i} hours"    if hours > 1
    words << "1 hour"                 if hours == 1
    words << "#{mins.to_i} minutes"   if mins > 1
    words << "1 minute"               if mins == 1
    words << "#{secs.to_i} seconds"   if secs > 1
    words << "1 second"               if secs == 1
    words << "0 seconds"              if words.empty?

    words.join(', ')
  end

  def elapsed
    Time.now - @start
  end

  def remaining
    return nil  if @current == 0
    elapsed * total / @current - elapsed
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

  def self.each(enumerable, options={}, &block)
    new(enumerable, options).each(&block)
  end
end
