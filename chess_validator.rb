require 'pry'
class ChessBoard
	attr_accessor :w_team, :b_team
	def initialize
		@w_team = {:pawn1 => Pawn.new("a2",self,"white"), :pawn2 => Pawn.new("b2",self,"white"),:pawn3 => Pawn.new("c2",self,"white"),:pawn4 => Pawn.new("d2",self,"white"),
				   :pawn5 => Pawn.new("e2",self,"white"), :pawn6 => Pawn.new("f2",self,"white"),:pawn7 => Pawn.new("g2",self,"white"),:pawn8 => Pawn.new("h2",self,"white"),
				   :rook1 => Rook.new("a1",self,"white"), :rook2 => Rook.new("h1",self,"white"),:knight1 => Knight.new("b1",self,"white"),:knight2 => Knight.new("g1",self,"white"),
				   :bishop1 => Bishop.new("c1",self,"white"),:bishop2 => Bishop.new("f1",self,"white"),:queen => Queen.new("d1",self,"white"),:king => King.new("e1",self,"white")}
		@b_team = {:pawn1 => Pawn.new("a7",self,"black"), :pawn2 => Pawn.new("b7",self,"black"),:pawn3 => Pawn.new("c7",self,"black"),:pawn4 => Pawn.new("d7",self,"black"),
				   :pawn5 => Pawn.new("e7",self,"black"), :pawn6 => Pawn.new("f7",self,"black"),:pawn7 => Pawn.new("g7",self,"black"),:pawn8 => Pawn.new("h7",self,"black"),
				   :rook1 => Rook.new("a8",self,"black"), :rook2 => Rook.new("h8",self,"black"),:knight1 => Knight.new("b8",self,"black"),:knight2 => Knight.new("g8",self,"black"),
				   :bishop1 => Bishop.new("c8",self,"black"),:bishop2 => Bishop.new("f8",self,"black"),:queen => Queen.new("d8",self,"black"),:king => King.new("e8",self,"black")}
	end

	def move_piece(initial, final)
		if final[0].downcase.ord > "h".ord || final[1].to_i > 8 || final[1].to_i < 1
			p "OUT OF BOARD"
		else
			piece = get_piece(initial[0], initial[1].to_i)
			if piece != nil
				piece[1].move(final)
			end
		end
	end

	def get_piece(column, row)
		piece = check_team_pieces(@w_team,column,row)
		if piece == nil
			piece = check_team_pieces(@b_team,column,row)
		else
			piece
		end
	end

	def check_team_pieces(team, column, row)
		the_piece = nil
		team.each do |piece|
			if piece[1].x_position == column && piece[1].y_position == row
				the_piece = piece
			end
		end
		the_piece
	end

	def draw_board
		row = [*1..8].reverse
		column = [*"a" .. "h"]
		print "\n\n\t"
		row.each do |r|
			column.each do |c|
				piece = get_piece(c,r)
				draw_position(piece,c,r)
			end
		end
	end
	def draw_position(piece,column,row)
		if piece == nil
			print "-- "
		else
			if piece[1] == "deleted"
				print "-- "
			else
				if piece[1].color == "white"
					print "w"
				else
				 	print "b"
				end
				case piece[1].class.name
					when "Rook" then print "R "
					when "Bishop" then print "B "
					when "Knight" then print "N "
					when "Queen" then print "Q "
					when "King" then print "K "
					when "Pawn" then print "P "
				end
			end
		end
		if column == "h" && row != 1
			print "\n\t"
		elsif column == "h" && row == 1
			print "\n\n"
		end
	end

	def read_match(file)
		movements = IO.read(file).split("\n")
		system("clear")
		self.draw_board
		movements.each do |move|
			movement = move.split(" ")
			sleep(3)
			system("clear")
			self.move_piece(movement[0],movement[1])
			self.draw_board
			p "Movement: " + movement[0] + " to " + movement[1] 
		end
	end

	def play
		system("clear")
		self.draw_board
		while true
			command = gets.chomp
			if command != "exit"
				command = command.split(" ") 
				if command[1]
					result = eval 'self.move_piece("' + command[0] + '","' + command[1] + '")'
				end
			else 
				exit
			end
			system("clear")
			self.draw_board
			unless result
				p "Invalid movement, try again"
			end
		end
	end
end

class Piece
	attr_accessor :x_position, :y_position, :color
	def initialize(position, board, color)
		@x_position = position[0]
		@y_position = position[1].to_i
		@color = color
		@board = board
	end

	def valid_movement(path)
		is_correct = []
		path.each do |square|
			if square
				is_correct << square[1].color
			else
				is_correct << true
			end
		end

		if is_correct.size == 1 && is_correct[0] != self.color
			result = true
		else
			a = is_correct[0.. is_correct.length - 2].join("").gsub("true","")
			result = (a == "" && is_correct.last != self.color)
		end
		result
	end

	def print_result(result,x_final = 0,y_final = 0) 
		result ? legal(x_final,y_final) : ilegal
	end

	def check_route(move)
		path = []
		move.map { |square|	path << self.check_position(square[0], square[1]) }
		result = self.valid_movement(path)
		if result
			if self.color == "black" 
				eat_piece(self.color,move.last[0],move.last[1])
			elsif self.color == "white"
				eat_piece(self.color,move.last[0],move.last[1])
			end
		end
		result
	end

	def eat_piece(color,x,y)
		piece = self.check_position(x,y)
		return nil if piece == nil
		if color == "black" 
			@board.w_team.reject!{ |k| k == piece[0] }
		else
			@board.b_team.reject!{ |k| k == piece[0] }
		end
	end

	def legal(x_final, y_final)
		self.refresh_position(x_final, y_final)
		#p "LEGAL"
	end

	def ilegal
		p "ILEGAL movement found"
	end

	def check_position(column, row)
		@board.get_piece(column,row.to_i)
	end

	def refresh_position(x_final, y_final)
		@x_position = x_final
		@y_position = y_final
	end
end

class Rook < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && @y_position != y_final
			result = self.move_vertical(y_final)
		elsif @y_position == y_final && @x_position != x_final
			result = self.move_horizontal(x_final)
		else
			self.print_result(false)
		end
		result
	end

	def move_horizontal(x)
		if x_position.downcase.ord - 95 < x.downcase.ord - 96
			move = [*x_position.downcase.ord - 95 .. x.downcase.ord - 96]
		else
			move = [*x.downcase.ord - 96 .. x_position.downcase.ord - 95].reverse
		end
		move.each { |m| m.chr }
		result = check_route(move)

		self.print_result(result,x,@y_position)
		result
	end

	def move_vertical(y)
		if y_position + 1 < y
			move = [*@x_position + (y_position + 1).to_s .. @x_position + y.to_s]
		else
			move = [*@x_position + y.to_s + (y_position + 1).to_s].reverse
		end
		result = check_route(move)
		self.print_result(result,@x_position,y)
		result
	end
end

class Knight < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i
		if ( (@x_position.ord - x_final.ord).abs == 2 && (@y_position.ord - y_final.ord).abs == 1 ) ||
		   ( (@x_position.ord - x_final.ord).abs == 1 && (@y_position.ord - y_final.ord).abs == 2 )
			result = self.move_l(x_final, y_final)
			eat_piece(self.color,x_final,y_final)
		else
			self.print_result(false)
			result = false
		end
		result
	end

	def move_l(x_final, y_final)
		piece = check_position(x_final, y_final)
		if piece == nil || piece[1].color != self.color
			self.print_result(true,x_final, y_final)
			true
		else
			self.print_result(false)
			false
		end
	end
end

class Bishop < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if (@x_position.ord - x_final.ord).abs == (@y_position.ord - y_final.ord).abs
			result = self.move_diagonal(x_final, y_final)
		else
			self.print_result(false)
			result = false
		end
		result
	end

	def move_diagonal(x_final, y_final)
		if x_position.ord < x_final.ord
			x_move = [*(x_position.ord + 1).chr .. x_final]
		else
			x_move = [*x_final .. (x_position.ord - 1).chr].reverse
		end

		if y_position < y_final
			y_move = [*y_position + 1 .. y_final]
		else
			y_move = [*y_final .. y_position - 1].reverse
		end
		move = [*0..x_move.size - 1]
		path = move.map do |item|
			x_move[item] + y_move[item].to_s
		end

		result = check_route(path)
		self.print_result(result,x_final,y_final)
		result
	end
end

class Queen < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && @y_position != y_final
			result = self.move_vertical(y_final)
		elsif @y_position == y_final && @x_position != x_final
			result = self.move_horizontal(x_final)
		elsif (@x_position.ord - x_final.ord).abs == (@y_position.ord - y_final.ord).abs
			result = self.move_diagonal(x_final, y_final)
		else
			self.print_result(false)
			result = false
		end
		result
	end

	def move_horizontal(x)
		if x_position.downcase.ord - 95 < x.downcase.ord - 96
			move = [*x_position.downcase.ord - 95 .. x.downcase.ord - 96]
		else
			move = [*x.downcase.ord - 96 .. x_position.downcase.ord - 95].reverse
		end
		move.each { |m| m.chr }
		result = check_route(move)
		self.print_result(result,x,@y_position)
		result
	end

	def move_vertical(y)
		if y_position + 1 <= y
			move = [*@x_position + (y_position + 1).to_s .. @x_position + y.to_s]
		else
			move = [*@x_position + y.to_s + (y_position + 1).to_s].reverse
		end
		result = check_route(move)
		self.print_result(result,@x_position,y)
		result
	end

	def move_diagonal(x_final, y_final)
		if x_position.ord < x_final.ord
			x_move = [*(x_position.ord + 1).chr .. x_final]
		else
			x_move = [*x_final .. (x_position.ord - 1).chr].reverse
		end

		if y_position < y_final
			y_move = [*y_position + 1 .. y_final]
		else
			y_move = [*y_final .. y_position - 1].reverse
		end

		move = [*0..x_move.size - 1]
		path = move.map do |item|
			x_move[item] + y_move[item].to_s
		end

		result = check_route(path)
		self.print_result(result,x_final,y_final)
		result
	end
end

class King < Queen
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && (@y_position - y_final).abs == 1
			result = self.move_vertical(y_final)
		elsif @y_position == y_final && (@x_position.ord - x_final.ord).abs == 1
			result = self.move_horizontal(x_final)
		elsif (@x_position.ord - x_final.ord).abs == 1 && (@y_position.ord - y_final.ord).abs == 1
			result = self.move_diagonal(x_final, y_final)
		else
			self.print_result(false)
			result = false
		end
		result
	end
end

class Pawn < King
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && (@y_position - y_final).abs <= 2
			result = can_move(x_final, y_final)
		elsif (@x_position.ord - x_final.ord).abs == 1 && (@y_position.ord - y_final.ord).abs == 1
		 	result = can_eat(x_final, y_final)
		else
		 	self.print_result(false)
		 	result = false
		end
		result
	end

	def eat(x_final, y_final)
		piece = check_position(x_final,y_final)
		result = piece && piece[1].color != self.color
		self.print_result(result,x_final,y_final)
		result
	end

	def can_move(x_final, y_final)
		if @y_position - y_final == 1 && self.color == "black" #b_move_one
			result = self.move_vertical(y_final)
		elsif @y_position - y_final == -1 && self.color == "white" #w_move_one
			result = self.move_vertical(y_final)
		elsif @y_position - y_final == 2 && self.color == "black" && @y_position == 7 #b_move_two 
			result = self.move_vertical(y_final) 
		elsif @y_position - y_final == -2 && self.color == "white" && @y_position == 2 #w_move_two
			result = self.move_vertical(y_final) 
		else
			self.print_result(false)
			result = false
		end
		result 
	end

	def can_eat(x_final, y_final)
		if @y_position - y_final == 1 && self.color == "black"
		 	result = self.eat(x_final, y_final)
	 	elsif @y_position - y_final == -1 && self.color == "white"
	 		result = self.eat(x_final, y_final)
	 	else
			result = self.print_result(false)
		end
		result
	end
end

board = ChessBoard.new
board.play
#board.read_match("match1.txt")