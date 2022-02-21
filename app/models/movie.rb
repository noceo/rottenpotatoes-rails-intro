class Movie < ActiveRecord::Base
  @@ratings = ['G','PG','PG-13','R']

  mattr_accessor :ratings

  def self.with_ratings(ratings)
    where(rating: ratings)
  end
end
