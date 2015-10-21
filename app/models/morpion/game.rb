module Morpion
  class Box
    attr_accessor :i, :j, :player
    def initialize(i:, j:)
      self.i = i
      self.j = j
      self.player = :none
    end
    def to_s
      case player
      when :none
        '.'
      when :player_one
        'O'
      when :player_two
        'X'
      end
    end
  end

  class Board
    attr_accessor :boxes
    def initialize
      self.boxes = []
      (0 .. 9).each do |i|
        self.boxes << (0 .. 9).map { |j| Box.new(i: i, j: j) }
      end
    end
    def check_box(i, j)
      self.boxes[i][j].player == :none
    end
    def set_box(i, j, player)
      self.boxes[i][j].player = player
      check_game
    end
    def check_game
      (0 .. 9).each do |i|
        check_row(i)
      end
      (0 .. 9).each do |i|
        check_col(i)
      end
      (0 .. 9).each do |i|
        check_diag_upper_left_to_lower_right
      end
    end
    def check_row(row)
      (0 .. 5).each do |i|
        combination = []
        (0 .. 4).each do |j|
          # puts "checking row #{row} col #{i + j}"
          combination[j] = self.boxes[row][i + j].player
        end
        check_win(combination)
      end
    end
    def check_col(col)
      (0 .. 5).each do |i|
        combination = []
        (0 .. 4).each do |j|
          # puts "checking row #{i + j} col #{col}"
          combination[j] = self.boxes[i + j][col].player
        end
        check_win(combination)
      end
    end
    def check_diag_upper_left_to_lower_right
      (0 .. 5).each do |i|
        combination = []
        (0 .. 4).each do |j|
          # puts "checking row #{i + j} col #{i + j}"
          combination[j] = self.boxes[i + j][i + j].player
        end
        check_win(combination)
      end
    end
    def check_win(combination)
      nb_identical_pieces = 0
      (1 .. 4).each do |j|
        # print "Checking row #{row} col #{i + j - 1} and #{i + j} : "
        if combination[j - 1] == combination[j]
          # puts "Same! #{self.boxes[row][i + j - 1]} & #{self.boxes[row][i + j]}"
          nb_identical_pieces += 1
        else
          # puts "Not same! #{self.boxes[row][i + j - 1]} & #{self.boxes[row][i + j]}"
          break
        end
        if (nb_identical_pieces == 4)
          case combination[0]
          when :player_one
            puts 'Player 1 have won this game'
          when :player_two
            puts 'Player 2 have won this game'
          end
        end
      end
    end
    def to_s
      s_col_sep = '|'
      s_row_sep = "\n"
      (0 .. 9).map { |i| (0 .. 9).map { |j| self.boxes[i][j] }.join(s_col_sep) }.join(s_row_sep)
    end
  end

  class Game
    attr_accessor :board, :table_length
    def initialize
      self.board = Board.new
      @player_one_turn = true
    end
    def turn(i, j)
      if self.board.check_box(i, j)
        if @player_one_turn
          player_piece = :player_one
        else
          player_piece = :player_two
        end
        self.board.set_box(i, j, player_piece)
        # @player_one_turn = !@player_one_turn
      else
        puts 'Box not free, try again...'
      end
      show_board
    end
    def show_board
      puts self.board
    end
  end
end
