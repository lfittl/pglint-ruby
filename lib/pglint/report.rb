require 'net/http'

module Pglint
  class Report
    def self.files
      Dir.glob(Rails.root.join('tmp/pglint/*'))
    end
    
    def self.from_file(filename)
      filedata = JSON.parse(File.read(filename))
      data = {}
      data['queries'] = filedata['queries']
      data['postgres'] = {}
      data['postgres']['schema'] = Dbinfo.schema
      Report.new(data, filedata['title'], filename)
    end
    
    attr_reader :data, :title
    def initialize(data, title, sourcefile = nil)
      @data = data
      @title = title
      @sourcefile = sourcefile
    end
    
    def send!
      uri = URI.parse("https://pglint.io/r")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(title: @title, data: @data.to_json)
      
      response = http.request(request)
      if response.is_a?(Net::HTTPOK)
        report_url = JSON.parse(response.body)['report']['url']
        File.write(@sourcefile.gsub(".json", "") + ".url", report_url) if @sourcefile
        report_url
      else
        nil
      end
    rescue => e
      Rails.logger.error e.message if defined?(::Rails)
      nil
    end
  end
end