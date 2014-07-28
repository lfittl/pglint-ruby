module Pglint
  class AtomicOutput
    def initialize(filename = nil)
      @f = open_file(filename)
      @f.sync = true
    end

    def write(message)
      @f.write(message)
    #rescue Exception
      # do nothing
    end

    def close
      @f.close rescue nil
    end
    
    def path
      File.realpath @f.path
    end

  private
    def open_file(filename)
      if (FileTest.exist?(filename))
        open(filename, (File::WRONLY | File::APPEND))
      else
        create_file(filename)
      end
    end

    def create_file(filename)
      f = open(filename, (File::WRONLY | File::APPEND | File::CREAT))
      f.sync = true
      f
    end
  end
end