# frozen_string_literal: true

class ComTheTrainline
  def self.find(from, to, departure_at)
    departure_code = LocationAdapter.find(from).code
    return [] if departure_code.nil?

    arrival_code = LocationAdapter.find(to).code
    return [] if arrival_code.nil?
    departure_code
  end
end
