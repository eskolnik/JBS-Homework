=begin 

    A basic animal guessing game that proves that I've learned the bare basics of Ruby.
    Which I have. Booyah.

    version 1.5
	Copyright (c) 2012 Nobody

	This is expensive software, you can't distribute or modify
	this program uless you really really want to. 
	(http://www.youtube.com/watch?v=oHg5SJYRHA0)

=end


# A basic node object representing either a question or an animal. 
# The answer to a question is always the left child.
class Node
	attr_accessor :l_child, :r_child, :animal, :data

	def initialize(string, is_animal)
		@animal = is_animal # True if the node contains an animal, false if it contains a question
		@data = string
		@l_child = nil
		@r_child = nil
	end
	def to_s()
		if @animal
			type = "Question"
		else
			type = "Animal"
		end
		return "#{type} Node, left: #{l_child.data}, right: #{r_child.data}"
	end
end

# Takes three nodes and links them in a binary tree structure, returning the root node.
# This should really be part of the Node class, but in the original implementation it made sense for it to be separate, 
#  and I haven't gotten around to changing it. And probably never will. So it goes.  
def constructTree(parent, left, right)
	parent.l_child = left
	parent.r_child = right
	return parent
end

# To add an animal to the game, two nodes must be added and one displaced.
# This method ensures that the new question will have the new and old animals in the correct positions.
def addAnimal(parent, replace, animal, question, left = true)
	question = Node.new(question, false)
	answer = Node.new(animal, true)

	if replace == parent.l_child
		left ? constructTree(question, answer, parent.l_child) : constructTree(question, parent.l_child, answer)
		constructTree(parent, question, parent.r_child)
	else
		left ? constructTree(question, answer, parent.r_child) : constructTree(question, parent.r_child, answer)
		constructTree(parent, parent.l_child, question)
	end
end

# The main game loop. My while loop syntax may leave something to be desired, but it does work.
def game(node)
	puts "#{node.data} (y/n)"
	flag = true
	while(flag)
		response = gets.chomp
		flag = false
		case response
			when /y|yes/
				if  node.l_child.animal == true
					endGame(node.l_child, node)
				else
					game(node.l_child)
				end
			when /n|no/
				if node.r_child.animal == true
					endGame(node.r_child, node)
				else
					game(node.r_child)
				end
			else
				puts "not a valid response"
				flag = true
		end
	end
end

# If the program did not guess correctly, the user is prompted to enter his/her answer along with an accompanying question.
def endGame(guess, parent)
	puts "Is it a #{guess.data}?"
	flag = true
	while(flag)
		response = gets.chomp
		flag = false
		case response
			when /y|yes/
				puts "Beep boop, I win."
			when /n|no/
				puts "I give up. You win this time. What was the animal?"
				animal = gets.chomp
				puts "Enter a question that can distinguish between a #{animal} and a #{guess.data}"
				question = gets.chomp

				#by default, the new animal will be added in the 'yes' position, so user input is required to specify a 'no' response
				puts "Is the answer to your question #{animal}?"
				truth = gets.chomp =~ /y|yes/ ? true : false
				addAnimal(parent, guess, animal, question, truth)
			else
				puts "Not a valid response"
				flag = true
		end
	end

end

#The game tree is loaded recursively, with each question node making two more calls to the loadGameTree method
def loadGameTree(file)
	type = file.getc
	if type == 'a'
		node= Node.new(file.gets.chomp, true)
		#puts node.data
		return node
	else
		parent = file.gets.chomp
		l_node = loadGameTree(file)
		r_node = loadGameTree(file)
		root = Node.new(parent, false)
		constructTree(root, l_node, r_node)
		return root
	end
end


#The game tree is saved tail-recursively
def saveGameTree(file, node)
	type = node.animal ? 'a' : 'q'
	file.puts "#{type}#{node.data}"
	if type == 'q'
		saveGameTree(file, node.l_child)
		saveGameTree(file, node.r_child)
	end
end


if __FILE__ == $0
	file = File.open("gameTree.txt", "r+")
	root = loadGameTree(file)
	file.close

	puts"Animal Game"
	puts "Think of an animal, any animal. But DON'T think about elephants."
	puts "Press enter when ready."
	gets
	continue = true
	while(continue)
		#puts "hi"
		game(root)
		puts "Play again?"
		continue = gets.chomp =~ /y|yes/
	end
	puts "Saving new animal data..."
	file = File.open("gameTree.txt", "w+")
	saveGameTree(file, root)
	puts "Save complete."
end