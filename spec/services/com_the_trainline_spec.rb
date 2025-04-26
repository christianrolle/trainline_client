# frozen_string_literal: true
require 'rails_helper'

def stub_location_request(name)
  stub_request(:get, URI::HTTPS.build(host: 'www.thetrainline.com',
                                      path: '/api/locations-search/v2/search',
                                      headers: { 'Accept' => 'application/json',
                                                 'Content-Type' => 'application/json',
                                                 'User-Agent' => 'Friend' }))
    .with(query: { searchTerm: name, locale: 'de-DE' })
end

RSpec.describe ComTheTrainline do
  subject(:bot) { described_class.find('London', 'Paris', Time.current) }
  let(:departure_location_code) { 'urn:trainline:generic:loc:182gb' }
  let(:arrival_location_code) { 'urn:trainline:generic:loc:4916' }
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

  it 'searches departure location-ID at TheTrainline API' do
    subject
    expect(departure_location_request).to have_been_requested.once
  end

  it 'searches arrival location-ID at TheTrainline API' do
    subject
    expect(arrival_location_request).to have_been_requested.once
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
  end
  context 'with multiple departure locations' do
  end
end
