module Morpion
  class Box
    attr_accessor :i, :j, :player, :alignments
    def initialize(i:, j:)
      self.i = i
      self.j = j
      self.player = :none
      self.alignments = []
    end
    def belongs_to(alignment)
      alignment.boxes << self
      alignments << alignment
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
    attr_accessor :boxes, :alignments
    def initialize
      self.boxes = []
      (0 .. 9).each do |i|
        self.boxes << (0 .. 9).map { |j| Box.new(i: i, j: j) }
      end
      self.alignments = []
      (0 .. 9).each do |i|
        (0 .. 5).each do |j|
          alignment = Alignment.new
          (0 .. 4).each { |k| self.boxes[i][j + k].belongs_to(alignment) }
          self.alignments << alignment
        end
      end
      (0 .. 5).each do |i|
        (0 .. 9).each do |j|
          alignment = Alignment.new
          (0 .. 4).each { |k| self.boxes[i + k][j].belongs_to(alignment) }
          self.alignments << alignment
        end
      end
      (0 .. 5).each do |i|
        (0 .. 5).each do |j|
          alignment = Alignment.new
          (0 .. 4).each { |k| self.boxes[i + k][j + k].belongs_to(alignment) }
          self.alignments << alignment
        end
      end
      (0 .. 5).each do |i|
        (0 .. 5).each do |j|
          alignment = Alignment.new
          (0 .. 4).each { |k| self.boxes[i + k][4 + j - k].belongs_to(alignment) }
          self.alignments << alignment
        end
      end
    end
    def check_box(pos_x, pos_y)
      self.boxes[pos_y][pos_x].player == :none
    end
    def set_box(pos_x, pos_y, player)
      self.boxes[pos_y][pos_x].player = player
      check_game(pos_x, pos_y, player)
    end
    def check_game(pos_x, pos_y, player)
      i, combination, game_over = -4, [], false
      while !game_over && i <= 0 do
        combination = check_row(pos_x + i, pos_y)
        if combination.length == 5
          game_over = check_win(combination, player)
        end
        i += 1
      end
      i, combination = -4, []
      while !game_over && i <= 0 do
        combination = check_col(pos_x, pos_y + i)
        if combination.length == 5
          game_over = check_win(combination, player)
        end
        i += 1
      end
      i, combination = -4, []
      while !game_over && i <= 0 do
        combination = check_diag_upper_left_to_lower_right(pos_x + i, pos_y + i)
        if combination.length == 5
          game_over = check_win(combination, player)
        end
        i += 1
      end
      i, combination = -4, []
      while !game_over && i <= 0 do
        combination = check_diag_lower_left_to_upper_right(pos_x + i, pos_y - i)
        if combination.length == 5
          game_over = check_win(combination, player)
        end
        i += 1
      end
      if game_over
        game_over(player)
      end
    end
    def check_row(pos_x, pos_y)
      combination = []
      (0 .. 4).each do |i|
        if pos_x + i >= 0 && pos_x + i <= 9
          # puts "Checking row #{pos_y} col #{pos_x + i}" # Logs des scans
          combination << self.boxes[pos_y][pos_x + i].player
        end
      end
      combination
    end
    def check_col(pos_x, pos_y)
      combination = []
      (0 .. 4).each do |i|
        if pos_y + i >= 0 && pos_y + i <= 9
          # puts "Checking row #{pos_y + i} col #{pos_x}" # Logs des scans
          combination << self.boxes[pos_y + i][pos_x].player
        end
      end
      combination
    end
    def check_diag_upper_left_to_lower_right(pos_x, pos_y)
      combination = []
      (0 .. 4).each do |i|
        if pos_x + i >= 0 && pos_x + i <= 9 && pos_y + i >= 0 && pos_y + i <= 9
          # puts "Checking row #{pos_y + i} col #{pos_x + i}" # Logs des scans
          combination << self.boxes[pos_y + i][pos_x + i].player
        end
      end
      combination
    end
    def check_diag_lower_left_to_upper_right(pos_x, pos_y)
      combination = []
      (0 .. 4).each do |i|
        if pos_x + i >= 0 && pos_x + i <= 9 && pos_y - i >= 0 && pos_y - i <= 9
          # puts "Checking row #{pos_y - i} col #{pos_x + i}" # Logs des scans
          combination << self.boxes[pos_y - i][pos_x + i].player
        end
      end
      combination
    end
    def check_win(combination, player)
      nb_identical_pieces = 0
      (0 .. combination.length).each do |i|
        if combination[i] == player
          nb_identical_pieces += 1
        end
      end
      nb_identical_pieces == 5
    end
    # Afficher toutes les combinaisons possibles
    def debug_show_all_combination_possible
      alignments.each do |alignment|
        alignment.boxes.each do |box|
          box.player = :player_one
        end
        puts self
        alignment.boxes.each do |box|
          box.player = :none
        end
      end
    end
    # Afficher toutes les combinaisons possibles relatives à une box
    def debug_show
      (0 .. 9).each do |i|
        (0 .. 9).each do |j|
          boxes[i][j].alignments.each do |alignment|
            alignment.boxes.each do |box|
              box.player = :player_one
            end
          end
          puts self
          boxes[i][j].alignments.each do |alignment|
            alignment.boxes.each do |box|
              box.player = :none
            end
          end
        end
      end
    end
    def winning_shot
      result = alignments.select { |alignment| alignment.is_won? }
      result.count
    end
    def game_over(winner_s_nickname)
      puts "Game over! Winner is #{winner_s_nickname}!"
    end
    def to_s
      s_col_sep = '|'
      s_row_sep = "\n"
      (0 .. 9).map { |i| (0 .. 9).map { |j| self.boxes[i][j] }.join(s_col_sep) }.join(s_row_sep) # Affiche la board
    end
  end

  class Alignment
    attr_accessor :boxes
    def initialize
      self.boxes = []
    end
    def is_won?
      combination = boxes.map(& :player).uniq
      combination.count == 1 && combination.first != :none
    end
  end

  class Game
    attr_accessor :board, :alignments
    def initialize
      self.board = Board.new
      @player_one_s_turn = true
    end
    def turn(pos_x, pos_y)
      if self.board.check_box(pos_x, pos_y)
        if @player_one_s_turn
          player_piece = :player_one
        else
          player_piece = :player_two
        end
        self.board.set_box(pos_x, pos_y, player_piece)
        # @player_one_s_turn = !@player_one_s_turn
      else
        puts 'Box not free, try again...'
      end
      show_board
    end
    def row_win
      random_x = Random.rand(6)
      random_y = Random.rand(10)
      (0 .. 4).each do |i|
        turn(random_x + i, random_y)
      end
    end
    def col_win
      random_x = Random.rand(10)
      random_y = Random.rand(6)
      (0 .. 4).each do |i|
        turn(random_x, random_y + i)
      end
    end
    def diag_ul_lr_win
      random_x = Random.rand(6)
      random_y = Random.rand(6)
      (0 .. 4).each do |i|
        turn(random_x + i, random_y + i)
      end
    end
    def diag_ll_ur_win
      random_x = Random.rand(6)
      random_y = Random.rand(6)
      (0 .. 4).each do |i|
        turn(random_x + i, random_y + 4 - i)
      end
    end
    def show_board
      puts self.board
    end
  end
end
