# frozen_string_literal: true
require 'ostruct'

class LocationAdapter
  LOCALE = 'de-DE'

  def self.find(name)
    # We have to make a choice and consider the first one to be the most
    # reasonable due to  missing user-interaction
    OpenStruct.new all(by: name)['searchLocations'].first
  end

  def self.all(by:)
    Trainline::Connection.request 'locations-search/v2/search',
                                  params: { searchTerm: by, locale: LOCALE }
  end
end
