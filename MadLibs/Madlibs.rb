# Madlibs game
# Author: Ezra Skolnik

# Searches a text file for placeholder phrases inside double parentheses: ((a phrase))
# and prompts the user for a word to replace each instance with.
# Automatically replaces all instances of the same phrase with the same user response

puts "Enter file"
filename = gets.chomp
file = File.open "#{filename}", "r"
story = file.read
story_remain = story
phrases = []

#find the first placeholder in the remaining story and save it in the phrases array
while /\(\(([^\)]*)\)\)/ =~ story_remain
	phrases[phrases.length] = $1
	story_remain = $' # remove the part of the story already scanned
end

#prompt the user for a resonse to each phrase and make the replacement in the original story
phrases.uniq.collect do |x|
	puts "Enter #{x}"
	replace = gets.chomp
	story.gsub!("((#{x}))", replace)
end
print story