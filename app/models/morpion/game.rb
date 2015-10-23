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
    def is_free?(pos_x, pos_y)
      self.boxes[pos_y][pos_x].player == :none
    end
    def set_box(pos_x, pos_y, player)
      self.boxes[pos_y][pos_x].player = player
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
    def computer_priority
      priority = [1, 2, 3, 4, 5]
      best_priority, best_pos_x, best_pos_y = 0, 0, 0
      # box = alignments.select { |alignment| alignment.boxes.map(& :player_one) }
      # priority[box.count]
      (0 .. 9).each do |i|
        (0 .. 9).each do |j|
          temp_priority = 0
          boxes[i][j].alignments.each do |alignment|
            alignment.boxes.each do |box|
              if box.player = :player_one
                temp_priority += 1
              end
            end
          end
        end
      end
    end
    def winning_shot
      result = alignments.select { |alignment| alignment.is_won? }
      result.count > 0
    end
    def tying_shot
      result = alignments.select { |alignment| !alignment.is_tie? }
      result.count == 0
    end
    def game_over(winner_s_nickname)
      puts "Game over! Winner is #{winner_s_nickname}!"
    end
    def to_s
      s_col_sep = ' | '
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
    def is_tie?
      combination = boxes.map(& :player).uniq
      combination.include?(:player_one) && combination.include?(:player_two)
    end
  end

  class Game
    attr_accessor :board, :alignments
    def initialize
      self.board = Board.new
      @player_one_s_turn, @game_over = true, false
      player_s_turn
    end
    def player_s_turn
      if @player_one_s_turn
        puts "#{:player_one.capitalize}'s turn"
      else
        puts "#{:player_two.capitalize}'s turn"
      end
    end
    def turn(pos_x, pos_y)
      if !@game_over
        if self.board.is_free?(pos_x, pos_y)
          if @player_one_s_turn
            player_piece = :player_one
          else
            player_piece = :player_two
          end
          self.board.set_box(pos_x, pos_y, player_piece)
          if self.board.winning_shot
            self.board.game_over(player_piece)
            @game_over = true
          elsif self.board.tying_shot
            puts 'Sorry, no winner this time'
            @game_over = true
          end
          # @player_one_s_turn = !@player_one_s_turn
        else
          puts 'Box not free, try again...'
        end
        show_board
      else
        puts 'Game is over, launch a new one if you want to play'
      end
    end
    def show_board
      puts self.board
      player_s_turn
    end
  end
end
