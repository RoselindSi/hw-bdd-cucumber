# app/models/movie.rb
class Movie < ApplicationRecord
    # Canonical set for the assignment; keeps order predictable.
    ALL_RATINGS = %w[G PG PG-13 R].freeze
  
    # Return all available ratings (stable order for UI)
    def self.all_ratings
      ALL_RATINGS
    end
  
    # Flexible finder used by the controller:
    # - ratings: Array of ratings (e.g., ["PG","R"]) or nil/blank for all
    # - sort:    "title" or "release_date" or nil
    def self.with_ratings(ratings = nil, sort = nil)
      scope =
        if ratings.present?
          where(rating: ratings)
        else
          all
        end
  
      if %w[title release_date].include?(sort.to_s)
        scope.order(sort)
      else
        scope
      end
    end
  end
  