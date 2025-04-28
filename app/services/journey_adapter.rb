# frozen_string_literal: true
require 'ostruct'

class JourneyAdapter
  attr_reader :journeys, :sections, :alternatives, :fares, :legs, :locations, :fare_types
  COMFORT_CLASS_MAP = {
    'first' => 1,
    'economy' => 2
  }.freeze

  def initialize(data)
    @journeys = data.dig 'data', 'journeySearch', 'journeys'
    @sections = data.dig 'data', 'journeySearch', 'sections'
    @alternatives = data.dig 'data', 'journeySearch', 'alternatives'
    @fares = data.dig 'data', 'journeySearch', 'fares'
    @legs = data.dig 'data', 'journeySearch', 'legs'
    @locations = data.dig 'data', 'locations'
    @fare_types = data.dig 'data', 'fareTypes'
  end

  def self.transform(journey_data)
    new(journey_data).transform
  end

  def transform
    return [] if journeys.blank?

    journeys.values.map { |journey| build_segment(journey) }
  end

  private

  def build_segment(journey)
    departure_at = Time.parse(journey['departAt']).utc
    arrival_at = Time.parse(journey['arriveAt']).utc
    {
      departure_station: departure_station(journey),
      departure_at: departure_at,
      arrival_station: arrival_station(journey),
      arrival_at: arrival_at,
      service_agencies: ['thetrainline'],
      duration_in_minutes: ((arrival_at - departure_at).to_f / 60.0).round,
      changeovers: (journey['legs'].size - 1),
      products: ['train'],
      fares: build_fares(journey['sections'])
    }
  end

  def departure_station(journey)
    locations.dig legs.dig(journey['legs'].first, 'departureLocation'), 'name'
  end

  def arrival_station(journey)
    locations.dig legs.dig(journey['legs'].first, 'arrivalLocation'), 'name'
  end

  def build_fares(section_ids)
    section_ids.inject([]) do |fares, section_id|
      fares += sections.dig(section_id, 'alternatives').map do |alternative_id|
        build_fare(alternatives[alternative_id])
      end
    end
  end

  def build_fare(alternative)
    fare = fares[alternative['fares'].first] || []
    {
      name: fare_types.dig(fare['fareType'], 'name'),
      price_in_cents: (alternative.dig('fullPrice', 'amount').to_f * 100.0).to_i,
      currency: alternative.dig('fullPrice', 'currencyCode'),
      comfort_class: comfort_class(fare['fareLegs'].first)
    }
  end

  def comfort_class(fare_leg = {})
    comfort_class_type = fare_leg.dig('travelClass', 'code').to_s[/([^:]+)$/]
    COMFORT_CLASS_MAP[comfort_class_type]
  end
end
