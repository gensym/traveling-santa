require 'csv'
require 'haversine'
require 'byebug'


def destinations
  CSV.read('nice-kid-cities.csv', headers: true).map(&:to_h).map do |i|
    {
      city: i["City"],
      state: i["State"],
      lat: i["Latitude"].to_f,
      lon: i["Longitude"].to_f
    }
  end
end

def miles_between(loc1, loc2)
  Haversine.distance(loc1[:lat], loc1[:lon], loc2[:lat], loc2[:lon]).to_miles
end

@north_pole = { city: "North Pole", state: "Earth", lat: 90, lon: 135 }

def build_route(destinations)
  todo = Set.new(destinations)
  route = [@north_pole]

  until todo.empty?
    next_location_result = todo.inject(nil) do |m, v|
      dist = miles_between(route.last, v)
      if m.nil? || dist < m[:distance]
        {location: v, distance: dist}
      else
        m
      end
    end

    next_location = next_location_result[:location]
    todo.delete(next_location)
    route.push(next_location)
  end

  route.push @north_pole
end

def evaluate_route(locations)
  start_point = { location: @north_pole, distance: 0 }

  result = locations.inject(start_point) do |m, v|
    {
      distance: miles_between(m[:location], v),
      location: v
    }
  end

  result[:distance]
end

def print_route(route)
  route.each do |l|
    puts "#{l[:city]}, #{l[:state]}"
  end
end

route = build_route(destinations)

print_route(route)

puts "\n\n#{evaluate_route(route).round(2)} miles"