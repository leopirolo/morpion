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
      (0 .. 9).each do |i| # Debut des lignes
        check_row(i)
      end
      (0 .. 9).each do |i| # Debut des lignes
        check_col(i)
      end
      (0 .. 5).each do |i| # Debut des lignes
        check_diag_upper_left_to_lower_right(i)
      end
      (4 .. 9).each do |i| # Debut des lignes
        check_diag_lower_left_to_upper_right(i)
      end
    end
    def check_row(row)
      (0 .. 5).each do |i| # Debut de la combinaison a analyser
        combination = []
        (0 .. 4).each do |j| # Combinaison a analyser
          # puts "Checking row #{row} col #{i + j}" # Logs des scans
          combination[j] = self.boxes[row][i + j].player
        end
        check_win(combination)
      end
    end
    def check_col(col)
      (0 .. 5).each do |i| # Debut de la combinaison a analyser
        combination = []
        (0 .. 4).each do |j| # Combinaison a analyser
          # puts "Checking row #{i + j} col #{col}" # Logs des scans
          combination[j] = self.boxes[i + j][col].player
        end
        check_win(combination)
      end
    end
    def check_diag_upper_left_to_lower_right(row)
      (0 .. 5).each do |i| # Debut de la combinaison a analyser
        combination = []
        (0 .. 4).each do |j| # Combinaison a analyser
          # puts "Checking row #{row + j} col #{i + j}" # Logs des scans
          combination[j] = self.boxes[row + j][i + j].player
        end
        check_win(combination)
      end
    end
    def check_diag_lower_left_to_upper_right(row)
      (0 .. 5).each do |i| # Debut de la combinaison a analyser
        combination = []
        (0 .. 4).each do |j| # Combinaison a analyser
          # puts "Checking row #{row - j} col #{i + j}" # Logs des scans
          combination[j] = self.boxes[row - j][i + j].player
        end
        check_win(combination)
      end
    end
    def check_win(combination)
      nb_identical_pieces = 0
      (1 .. 4).each do |j|
        # print "Checking row #{row} col #{i + j - 1} and #{i + j} : " # Logs des scans, decocher aussi les puts ci-dessous
        if combination[j - 1] == combination[j]
          # puts "Same! #{self.boxes[row][i + j - 1]} & #{self.boxes[row][i + j]}" # Logs des scans
          nb_identical_pieces += 1
        else
          # puts "Not same! #{self.boxes[row][i + j - 1]} & #{self.boxes[row][i + j]}" # Logs des scans
          break # Casse l'analyse actuelle si combinaison non-gagnante afin d'optimiser les performances
        end
        if (nb_identical_pieces == 4)
          case combination[0]
          when :player_one
            game_over(:player_one)
          when :player_two
            game_over(:player_two)
          end
        end
      end
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

  class Game
    attr_accessor :board, :table_length
    def initialize
      self.board = Board.new
      @player_one_s_turn = true
    end
    def turn(i, j)
      if self.board.check_box(i, j)
        if @player_one_s_turn
          player_piece = :player_one
        else
          player_piece = :player_two
        end
        self.board.set_box(i, j, player_piece)
        @player_one_s_turn = !@player_one_s_turn
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
