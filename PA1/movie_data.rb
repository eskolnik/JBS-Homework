#load a data set into a list of review objects

class MovieData
	attr_accessor :data_file, :movie_file, :review_list, :user_list, :movie_list

	def initialize()
		@data_file = File.open("ml-100k/u.data", 'r')
		@movie_file = File.open("ml-100k/u.item", 'r')
		load_data
	end

	# when a MovieData object is initialized, lists of review objects, movie ids and User objects are created
	# also loads movie name data
	# note - it was in the spec to have this as a spearate method, but it makes more sense as part of the initializer, so i just called it from there
	def load_data()

		#create a list of review objects
		@review_list = @data_file.each_line.collect {|line| Review.new(line.split.collect {|x| x.to_i})} #converts each entry to an integer before storing

		#Users are stored in a hash with the user ids as keys
		@user_list = Hash.new

		# OPTIMIZE - User creation process is too slow
		# For every review, if the associated user is not in the user list, add that user and add that review to the user's lsit
		# otherwise, just add the review to that user's list of reviews
		@review_list.collect do |review| 
			if !@user_list.include? review.user_id 
				@user_list[review.user_id] = User.new(review.user_id)
			end

			@user_list[review.user_id].add_review(review)
		end
		# Format: id, name, releasedate, imdb site, genres
		movie_data = @movie_file.each_line.collect {|line| line.split(/\|/)}
		# essentially same process as users, but for movies
		@movie_list = Hash.new
		@review_list.collect do |review|
			if !@movie_list.include? review.movie_id
				@movie_list[review.movie_id] = Movie.new(review.movie_id, movie_data[review.movie_id][1])
			end

			@movie_list[review.movie_id].add_review(review)
		end

		@movie_list.each_value {|movie| movie.calculate_popularity}

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
	# FIXME - add movie name support
	class Movie
		attr_accessor :movie_id, :name, :reviews, :popularity

		def initialize (movie_id, name = 'placeholder')
			@movie_id = movie_id
			@reviews = []
			@name = name
		end

		def add_review (review)
			@reviews << review
		end

		# popularity scales directly with mean rating and logarithmically with number of reviews
		# I figured 
		# FIXME - still experimenting with different log bases for popularity
		def calculate_popularity
			sum = 0
			@reviews.each {|x| sum+=x.rating}
			mean_rating = sum.to_f / @reviews.length.to_f
			# length+1 to prevent 0 popularity
			@popularity = Math.log(@reviews.length+1,5) * mean_rating
		end

		def to_s
			return "#{@name}: Popularity = #{@popularity}"
		end
	end

	def popularity_list
		return @movie_list.values.sort_by {|movie| movie.popularity}.reverse
	end

	def print_popularity_list
		popularity_list.collect {|id| puts @movie_list[id]}
	end

	def popularity(movie_id)
		return @movie_list[movie_id].popularity
	end

end

data = MovieData.new()
puts data.popularity_list
pop_list = File.new("poplist.txt", 'w')
pop_list.puts data.popularity_list
pop_list.close


