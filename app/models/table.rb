class Table
  def self.new
    table_length = 10
    table = Array.new(table_length) { |i| Array.new(table_length) { |j| (i * 10) + j } }
  end

  def self.show
    table_length = 10
    line = '———————————————————————————————————————————————————————'

    puts line
    (0 .. table_length - 1).each do |i|
      (0 .. table_length - 1).each do |j|
        print "| #{i * table_length + j} "
      end
      puts '|'
      puts line
    end
  end
end
