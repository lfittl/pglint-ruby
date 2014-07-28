# Thread-local report singleton used to ease integration with frameworks

require 'pathname'

module Pglint
  class CurrentReport
    def self.start(title, logdir)
      logdir = Pathname.new(logdir)
      FileUtils.mkdir_p logdir
      filename = logdir.join('%s_%s.json' % [Date.today.strftime("%Y%m%d"), SecureRandom.uuid])
      Thread.current["pglint.target"] = AtomicOutput.new(filename)
      Thread.current["pglint.target"].write("{\"title\": \"%s\", \"started\": %d, \"queries\": [\n" % [title, Time.now.to_i])
    end
    
    def self.active?
      !Thread.current["pglint.target"].nil?
    end
    
    def self.add_query(hsh)
      return unless active?
      Thread.current["pglint.target"].write(hsh.to_json + ",\n")
    end
    
    def self.finish(metadata = nil)
      return unless active?
      filename = Thread.current["pglint.target"].path
      Thread.current["pglint.target"].write("{}], \"metadata\": %s}\n" % metadata.to_json)
      Thread.current["pglint.target"].close
      Thread.current["pglint.target"] = nil
      
      # FIXME: Cleanup old files
      
      filename
    end
  end
end