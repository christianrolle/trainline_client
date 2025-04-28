# frozen_string_literal: true

class ComTheTrainline
  def self.find(from, to, departure_at = Time.current)
    origin = LocationAdapter.find(from).code
    return [] if origin.nil?

    destination = LocationAdapter.find(to).code
    return [] if destination.nil?

    JourneyAdapter.transform JourneySearch.request(origin: origin,
                                                   destination: destination,
                                                   depart_after: departure_at)
  end
end
