module GzipHelper
  def gzip_json(object)
    sio = StringIO.new
    gz = Zlib::GzipWriter.new(sio)
    gz.write(object.to_json)
    gz.close
    sio.string
  end
end

RSpec.configure do |config|
  config.include GzipHelper
end
