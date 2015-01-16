require 'pry'
class ChessBoard
	attr_accessor :w_team, :b_team
	def initialize
		@w_team = {:knight => Knight.new("b2",self,"white"),:queen => Queen.new("d3",self,"white")}
		@b_team = {:rook2 => Rook.new("a4",self,"black")}
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
			result = (a == "" && is_correct[is_correct.size - 1] != self.color)
		end
		result
	end

	def print_result(result) 
		result ? print_legal : print_ilegal
	end

	def check_route(move)
		path = []
		move.map { |square|	path << self.check_position(square[0], square[1]) }
		result = self.valid_movement(path)
	end

	def print_legal
		p "LEGAL"
	end

	def print_ilegal
		p "ILEGAL"
	end

	def check_position(column, row)
		@board.get_piece(column,row.to_i)
	end
end

class Pawn < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && (@y_position - y_final).abs <= 2
			if @y_position - y_final == 1 && self.color == "black" #b_move_one
				self.move_one
			elsif @y_position - y_final == -1 && self.color == "white" #w_move_one
				self.move_one
			elsif @y_position - y_final == 2 && self.color == "black" && @y_position == 7 #b_move_two 
				self.move_two
			elsif @y_position - y_final == -2 && self.color == "white" && @y_position == 2 #w_move_two
				self.move_two
			end
		elsif (@x_position.ord - x_final.ord).abs == 1 && (@y_position.ord - y_final.ord).abs == 1
			if @y_position - y_final == 1 && self.color == "black"
				self.eat
			elsif @y_position - y_final == -1 && self.color == "white"
				self.eat
			end
		else
			self.print_result(false)
		end
	end

end

class Rook < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && @y_position != y_final
			self.move_vertical(y_final)
		elsif @y_position == y_final && @x_position != x_final
			result = self.move_horizontal(x_final)
		else
			self.print_result(false)
		end
	end

	def move_horizontal(x)
		if x_position.downcase.ord - 95 < x.downcase.ord - 96
			move = [*x_position.downcase.ord - 95 .. x.downcase.ord - 96]
		else
			move = [*x.downcase.ord - 96 .. x_position.downcase.ord - 95].reverse
		end
		move.each { |m| m.chr }
		result = check_route(move)
		self.print_result(result)
	end

	def move_vertical(y)
		if y_position + 1 < y
			move = [*@x_position + (y_position + 1).to_s .. @x_position + y.to_s]
		else
			move = [*@x_position + y.to_s + (y_position + 1).to_s].reverse
		end
		result = check_route(move)
		self.print_result(result)
	end
end

class Knight < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i
		if ( (@x_position.ord - x_final.ord).abs == 2 && (@y_position.ord - y_final.ord).abs == 1 ) ||
		   ( (@x_position.ord - x_final.ord).abs == 1 && (@y_position.ord - y_final.ord).abs == 2 )
			self.move_l(x_final, y_final)
		else
			self.print_result(false)
		end
	end

	def move_l(x_final, y_final)
		piece = check_position(x_final, y_final)
		if piece == nil || piece[1].color != self.color
			self.print_result(true)
		else
			self.print_result(false)
		end
	end
end

class Bishop < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if (@x_position.ord - x_final.ord).abs == (@y_position.ord - y_final.ord).abs
			self.move_diagonal(x_final, y_final)
		else
			self.print_result(false)
		end
	end

	def move_diagonal(x_final, y_final)
		if x_position.downcase.ord - 95 < x_final.downcase.ord - 96
			x_move = [*(x_position.ord + 1).chr.downcase .. x_final.downcase]
		else
			x_move = [*x_final.downcase .. (x_position.ord + 1).chr.downcase].reverse
		end

		if y_position < y_final
			y_move = [*y_position + 1 .. y_final]
		else
			y_move = [*y_final .. y_position + 1].reverse
		end

		move = [*0..x_move.size - 1]
		path = move.map do |item|
			x_move[item] + y_move[item].to_s
		end

		result = check_route(path)
		self.print_result(result)
	end
end

class Queen < Piece
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && @y_position != y_final
			self.move_vertical(y_final)
		elsif @y_position == y_final && @x_position != x_final
			result = self.move_horizontal(x_final)
		elsif (@x_position.ord - x_final.ord).abs == (@y_position.ord - y_final.ord).abs
			self.move_diagonal(x_final, y_final)
		else
			self.print_result(false)
		end
	end

	def move_horizontal(x)
		if x_position.downcase.ord - 95 < x.downcase.ord - 96
			move = [*x_position.downcase.ord - 95 .. x.downcase.ord - 96]
		else
			move = [*x.downcase.ord - 96 .. x_position.downcase.ord - 95].reverse
		end
		move.each { |m| m.chr }
		result = check_route(move)
		self.print_result(result)
	end

	def move_vertical(y)
		if y_position + 1 <= y
			move = [*@x_position + (y_position + 1).to_s .. @x_position + y.to_s]
		else
			move = [*@x_position + y.to_s + (y_position + 1).to_s].reverse
		end
		result = check_route(move)
		self.print_result(result)
	end

	def move_diagonal(x_final, y_final)
		if x_position.downcase.ord - 95 < x_final.downcase.ord - 96
			x_move = [*(x_position.ord + 1).chr.downcase .. x_final.downcase]
		else
			x_move = [*x_final.downcase .. (x_position.ord + 1).chr.downcase].reverse
		end

		if y_position < y_final
			y_move = [*y_position + 1 .. y_final]
		else
			y_move = [*y_final .. y_position + 1].reverse
		end

		move = [*0..x_move.size - 1]
		path = move.map do |item|
			x_move[item] + y_move[item].to_s
		end

		result = check_route(path)
		self.print_result(result)
	end
end

class King < Queen
	def move(final)
		x_final = final[0]
		y_final = final[1].to_i

		if @x_position == x_final && (@y_position - y_final).abs == 1
			self.move_vertical(y_final)
		elsif @y_position == y_final && (@x_position.ord - x_final.ord).abs == 1
			result = self.move_horizontal(x_final)
		elsif (@x_position.ord - x_final.ord).abs == 1 && (@y_position.ord - y_final.ord).abs == 1
			self.move_diagonal(x_final, y_final)
		else
			self.print_result(false)
		end
	end
end

board = ChessBoard.new
board.move_piece("b2","c3")
board.move_piece("b2","a4")
board.move_piece("b2","c4")