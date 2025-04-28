# frozen_string_literal: true

class ZippedJsonParser
  def self.parse(zipped_json)
    zipper = Zlib::GzipReader.new StringIO.new(zipped_json)
    json = zipper.read
    zipper.close
    JSON.parse json
  end
end
