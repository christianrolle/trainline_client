# frozen_string_literal: true

class JourneySearch
  DEFAULT_PARAMETERS = {
    passengers: [{ id: 'pid-0', dateOfBirth: '2000-01-23', cardIds: [] }],
    isEurope: true,
    cards: [],
    type: 'single',
    maximumJourneys: 5,
    includeRealtime: true,
    transportModes: ['mixed'],
    directSearch: false,
    composition: ['through', 'interchangeSplit'],
    autoApplyCorporateCodes: false,
    requestedCurrencyCode: 'EUR'
  }.freeze

  def self.request(origin:, destination:, depart_after:)
    payload = DEFAULT_PARAMETERS.merge transitDefinitions: [{
                                         direction: 'outward',
                                         origin: origin,
                                         destination: destination,
                                         journeyDate: {
                                           type: 'departAfter',
                                           time: depart_after.iso8601
                                         }}]
    Trainline::Connection.request('journey-search',
                                  method: :post,
                                  body: payload,
                                  headers: { 'Accept-Encoding' => 'gzip' },
                                  parser: ZippedJsonParser)
  end
end
