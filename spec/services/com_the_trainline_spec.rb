# frozen_string_literal: true
require 'rails_helper'

def uri_for(path, headers: {})
  URI::HTTPS.build(host: 'www.thetrainline.com',
                   path: path,
                   headers: headers.merge({ 'Accept' => 'application/json',
                                            'Content-Type' => 'application/json',
                                            'x-version' => '4.42.30718',
                                            'User-Agent' => 'Mozilla/5.0' }))
end

def stub_location_request(name)
  stub_request(:get, uri_for('/api/locations-search/v2/search'))
    .with(query: { searchTerm: name, locale: 'de-DE' })
end

def stub_journey_request(origin, destination, depart_after)
  stub_request(:post, uri_for('/api/journey-search', headers: { 'Accept-Encoding' => 'gzip' }))
    .with(body: { passengers: [{ id: 'pid-0', dateOfBirth: '2000-01-23', cardIds: [] }],
                  isEurope: true,
                  cards: [],
                  type: 'single',
                  maximumJourneys: 5,
                  includeRealtime: true,
                  transportModes: ['mixed'],
                  directSearch: false,
                  composition: ['through', 'interchangeSplit'],
                  autoApplyCorporateCodes: false,
                  requestedCurrencyCode: 'EUR',
                  transitDefinitions: [{ direction: 'outward',
                                         origin: origin,
                                         destination: destination,
                                         journeyDate: { type: 'departAfter',
                                                        time: depart_after.utc.iso8601 }}]
                }.to_json)
end

RSpec.describe ComTheTrainline do
  let(:departure_time) { DateTime.new(2025, 4, 28) }
  let(:departure_location_code) { 'urn:trainline:generic:loc:182gb' }
  let(:arrival_location_code) { 'urn:trainline:generic:loc:4916' }
  let(:journeys_response) do
    {
      journeySearch: {
        journeys: {
          'journey-123': {
            sections: ['section-123'],
            legs: ['leg-123'],
            departAt: DateTime.new(2025, 4, 28, 1).iso8601,
            arriveAt: DateTime.new(2025, 4, 28, 2).iso8601
          }
        },
        alternatives: {
          'alternative-123': {
            fullPrice: { amount: 1.23, currencyCode: 'EUR' },
            fares: ['fare-123']
          }
        },
        fares: {
          'fare-123': {
            fareLegs: [{ travelClass: { code: 'urn:test:class:economy' } }],
            fareType: 'fare-type-123'
          }
        },
        legs: {
          'leg-123': { arrivalLocation: 'destination-123', departureLocation: 'origin-123' }
        },
        sections: { 'section-123': { alternatives: ['alternative-123'] }}
      },
      locations: {
        'origin-123': { name: 'London central station' },
        'destination-123': { name: 'Paris central station' }
      },
      fareTypes: { 'fare-type-123': { name: 'Test offer' } }
    }
  end
  let!(:departure_location_request) do
    stub_location_request('London')
      .and_return(status: 200,
                  body: { searchLocations: [{ code: departure_location_code }]}.to_json)
  end
  let!(:arrival_location_request) do
    stub_location_request('Paris')
      .and_return(status: 200,
                  body: { searchLocations: [{ code: arrival_location_code }]}.to_json)
  end

  let!(:journey_search_request) do
    stub_journey_request(departure_location_code, arrival_location_code, departure_time)
      .to_return(status: 200, body: gzip_json(data: journeys_response))
  end

  subject(:bot) { described_class.find('London', 'Paris', departure_time) }

  it 'searches departure location-ID at TheTrainline API' do
    subject
    expect(departure_location_request).to have_been_requested.once
  end

  it 'searches arrival location-ID at TheTrainline API' do
    subject
    expect(arrival_location_request).to have_been_requested.once
  end

  it 'returns segments' do
    expect(subject).to match_array([{
      departure_station: 'London central station',
      departure_at: DateTime.new(2025, 4, 28, 1).utc,
      arrival_station: "Paris central station",
      arrival_at: DateTime.new(2025, 4, 28, 2).utc,
      service_agencies: ['thetrainline'],
      duration_in_minutes: 60,
      changeovers: 0,
      products: ['train'],
      fares: [{ name: 'Test offer', price_in_cents: 123, currency: 'EUR', comfort_class: 2 }] 
    }])
  end

  context 'when search blank' do
    let!(:journey_search_request) do
      stub_journey_request(departure_location_code, arrival_location_code, departure_time)
        .to_return(status: 400, body: gzip_json({}))
    end
  
    it 'returns blank segments' do
      expect(subject).to be_empty
    end
  end

  context 'when location unknown' do
    let!(:departure_location_request) do
      stub_location_request('London').and_return(body: { searchLocations: []}.to_json)
    end
    it 'returns zero journeys' do
      expect(subject).to be_empty
    end
    it 'skips searching for arrival location-ID at TheTrainline API' do
      subject
      expect(arrival_location_request).not_to have_been_requested
    end
    it 'skips searching for journey at TheTrainline API' do
      subject
      expect(journey_search_request).not_to have_been_requested
    end
  end
end
