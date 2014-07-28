require 'erb'
require 'yaml'
require 'sinatra/base'

module Pglint
  class Web < Sinatra::Base
    set :root, File.expand_path(File.dirname(__FILE__) + "/../../web")
    set :public_folder, Proc.new { "#{root}/assets" }
    set :views, Proc.new { "#{root}/views" }
    set :locales, ["#{root}/locales"]
    
    get '/' do
      @requests = []
      Dir.glob(Rails.root.join('tmp/pglint/*')).each do |filename|
        data = File.read(filename)
        data = JSON.parse(data) rescue nil
        if data
          # LALA
          
        end
        @requests << data if data
      end
      @requests.sort_by! {|r| r['started'] }
      erb :dashboard
    end
  end
end