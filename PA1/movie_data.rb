#load a data set into a list of review objects

class MovieData
	attr_accessor :review_list, :user_list, :movie_list

	# when a MovieData object is initialized, lists of review objects, movie ids and User objects are created
	def initialize(file)

		#create a list of review objects
		@review_list = file.each_line.collect {|line| Review.new(line.split.collect {|x| x.to_i})} #converts each entry to an integer before storing

		#Users are stored in a hash with the user ids as keys
		@user_list = Hash.new

		# OPTIMIZE - User creation process is too slow
		# For every review, if the associated user is not in the user list, add that user and add that review to the user's lsit
		# otherwise, just add the review to that user's list of reviews
		@review_list.collect do |review| 
			if @user_list.include? review.user_id 
				@user_list[review.user_id] = User.new(review.user_id).add_review(review)
			else
				@user_list[review.user_id].add_review(review)
			end
		end

		# same process as users, but for movies
		@movie_list = Hash.new
		@review_list.collect do |review|
			if @movie_list.include? review.movie_id
				@movie_list[review.movie_id] = Movie.new(review.movie_id)
			end
		end

		@movie_list.each {|movie| movie.calculate_popularity}

	end

	# The review class contains the basic data about each review: user id, movie id, rating, and timestamp
	class Review
		attr_accessor :user_id, :movie_id, :rating, :timestamp

		def initialize (data)
			@user_id = data[0]
			@movie_id = data[1]
			@rating = data[2]
			@timestamp = data[3]
		end

		def to_s
			return "User: #{user_id}, Movie: #{movie_id}, Rating #{rating}, Timestamp: #{timestamp}"
		end
	end

	class User 
		attr_accessor :user_id, :ratings_list, :genre_prefs

		def initialize (id)
			@user_id = id
			@ratings_list = []
		end

		def add_review (review)
			@ratings_list << review
		end
	
		def to_s 
			return "ID: #{user_id}"
		end

	end

	class Movie
		attr_accessor :movie_id, :reviews, :popularity

		def initialize (movie_id)
			@movie_id = movie_id
			@reviews = []
		end

		def add_review (review)
			@reviews << review
		end

		# popularity scales directly with mean rating and logarithmically with number of reviews
		# FIXME - still experimenting with different log bases for popularity
		def calculate_popularity
			sum = 0
			@reviews.each {|x| sum+=x.rating}
			mean_rating = sum.to_f / @reviews.length.to_f
			@popularity = Math.log(ratings.length, 3) * mean_rating
		end

		def to_s
			return "ID: #{@movie_id}, Popularity: #{@popularity}"
		end
	end

end

file = File.open("ml-100k/testset.data", 'r')
data = MovieData.new(file)
puts data.review_list[0].rating
puts data.popularity(data.review_list[0].movie_id)