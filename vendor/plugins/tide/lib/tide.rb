require 'tide_path.rb'

module Tide
  
  class TideFatalException < StandardError #:nodoc:
  end

# Returns the raw data from the tide executable for the set of +options+ 
  # provided. 
  # 
  # Options are:
  # 
  # * <tt>:b</tt> -- Specifies the begin (start) time for predictions as a <tt>Time</tt> 
  #   object. The timezone is ignored and is assumed to be in the local time 
  #   zone for the location, or in UTC if the <tt>:z</tt> option is used. If no 
  #   <tt>:b</tt> is supplied, the current time will be used.
  # * <tt>:e</tt> -- Specifies the end (stop) time for predictions as a <tt>Time</tt>
  #   object. The timezone is ignored and is assumed to be in the local time
  #   zone for the location, or in UTC if the <tt>:z</tt> option is used. If no 
  #   <tt>:e</tt> is supplied, the end time will be set to four days after the 
  #   begin time.
  # * <tt>:z</tt> -- if true, returns all times in UTC
  # * <tt>:f</tt> -- Value = "c|h|i|l|p|t" Specify the output format as CSV, 
  #   HTML, iCalendar, LaTeX, PNG, or text. The default is text.
  # * <tt>:l</tt> -- Value = "Location Name" You can use the <tt>:l</tt> option
  #   more than once if you want to specify multiple locations.
  # * <tt>:m</tt> -- Value = "a|b|c|C|g|l|m|p|r|s" Specify mode to be about, 
  #   banner, calendar, alt. calendar, graph, list, medium rare, plain, raw, or 
  #   stats. The default is plain.
  # * <tt>:ml</tt> -- Value = "[-]N.NN(ft|m|kt)" Specify the mark level to be used 
  #   in predictions. The predictions will include the times when the tide level 
  #   crosses the mark. Example usage: <tt>:ml => "-0.25ft"</tt>
  # * <tt>:o</tt> -- Redirect output to the specified filename (appends).
  # * <tt>:s</tt> -- Value = "HH:MM" Specify the step interval, in hours and 
  #   minutes, for raw or medium rare mode predictions.  The default is one hour.
  #
  # When it matters, <tt>:b</tt> and <tt>:e</tt> ranges mean specifically 
  # "all t such that b <= t < e." The timezone of the passed in <tt>Time</tt>
  # object is ignored and is parsed using the <tt>Time.strftime()</tt> method with a
  # parameter of "%Y-%m-%d %H:%M". This formats the date into the required
  # "YYYY-MM-DD HH:MM" format required by the tide executable.
  def Tide.execute(options = {})
      command = String.new TidePath.get()
      if options.kind_of? Hash

        if options.key?(:b)
          b = options[:b].strftime("%Y-%m-%d %H:%M")
          command << " -b \"#{b}\""
        end

        if options.key?(:e)
          e = options[:e].strftime("%Y-%m-%d %H:%M")
          command << " -e \"#{e}\""
        end

        if options[:z]
          command << " -z"
        end

        if options.key?(:f)
          command << " -f #{options[:f]}"
        end

        if options.key?(:l)
          location = options[:l]
          if location =~ /"/
            command << " -l '#{location}'"
          else
            command << " -l \"#{location}\""
          end
        end

        if options.key?(:m)
          command << " -m #{options[:m]}"
        end

        if options.key?(:ml)
          command << " -ml #{options[:ml]}"
        end

        if options.key?(:o)
          command << " -o \"#{options[:o]}\""
        end

        if options.key?(:s)
          s = options[:s]
          command << " -s \"#{s}\""
        end

        if options[:v]
          command << " -v"
        end
      else
        command << options
      end

      data = IO.popen(command)
      raw_data = data.readlines
      data.close
      
      if raw_data.empty?
        raise TideFatalException.new("No results returned for command: #{command}")
      else
        return raw_data
      end
  end

  # tide -m l
  def Tide.list
    Tide.execute({:m => 'l'})
  end
  
  # tide -m l -f h
  def Tide.list_html
    Tide.execute({:m => 'l', :f => 'h'})
  end
  
  # tide -m a -l +name+
  def Tide.about(name)
    Tide.execute({:m => 'a', :l => name})
  end
  
  # tide -m a -f h -l +name+
  def Tide.about_html(name)
    Tide.execute({:m => 'a', :f => 'h', :l => name})
  end
  
  # tide -l +name+ -b +begin_time+ -e +end_time+ -z
  def Tide.plain(name, begin_time = nil, end_time = nil, utc = true)
    cmd = { :l => name, :z => utc }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end

  # tide -l +name+ -b +begin_time+ -e +end_time+ -z -f c
  def Tide.plain_csv(name, begin_time = nil, end_time = nil, utc = true)
    cmd = { :l => name, :z => utc, :f => 'c' }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end
  
  # tide -m r -l +name+ -b +begin_time+ -e +end_time+ -z -s +interval+
  def Tide.raw(name, begin_time = nil, end_time = nil, utc = true, interval = "00:15")
    cmd = { :m => 'r', :l => name, :s => interval, :z => utc }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end
  
  # tide -m r -l +name+ -b +begin_time+ -e +end_time+ -z -f c
  def Tide.raw_csv(name, begin_time = nil, end_time = nil, utc = true, interval = "00:15")
    cmd = { :m => 'r', :l => name, :s => interval, :z => utc, :f => 'c' }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end
  
  # tide -m m -l +name+ -b +begin_time+ -e +end_time+ -z
  def Tide.medium_rare(name, begin_time = nil, end_time = nil, utc = true)
    cmd = { :m => 'm', :l => name, :z => utc }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end
  
  # tide -m m -l +name+ -b +begin_time+ -e +end_time+ -z -f c
  def Tide.medium_rare_csv(name, begin_time = nil, end_time = nil, utc = true)
    cmd = { :m => 'm', :l => name, :z => utc, :f => 'c' }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end
  
  # tide -s m -l +name+ -b +begin_time+ -e +end_time+ -z
  def Tide.stats(name, begin_time = nil, end_time = nil, utc = true)
    cmd = { :m => 's', :l => name, :z => utc }
    cmd[:b] = begin_time if begin_time
    cmd[:e] = end_time if end_time
    Tide.execute(cmd)
  end
  
end

