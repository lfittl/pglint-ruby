# Runs Report#send! in a separate thread and later yields the result
#
# Note: This class is a singleton to ease integration with frameworks

module Pglint
  class ThreadedSend
    def self.start!(filename)
      raise "Threaded send already running" if @thread
      
      @thread = Thread.new do
        report = Pglint::Report.from_file(filename)
        
        # FIXME: Don't fail if internet connection is down (use a really short timeout)
        Thread.current[:url] = report.send!
        
        Thread.current.exit
      end
    end
    
    def self.active?
      !@thread.nil?
    end
    
    def self.result
      raise "No thread running" unless @thread
      @thread.join
      url = @thread[:url]
      @thread = nil
      url
    end
  end
end