class AirlineSeatingArrangement
 attr_accessor :max_seats, :total_passenger, :invalid_msg, :max_columns, :sitting_arrangements
  
  def initialize(*args)
    @invalid_msg = validate_given_details(args)
    if @invalid_msg.nil?
      initialize_attributes
    end
  end

  def initialize_attributes
    @passengers_seated = 0
    @max_seats = @given_seats.map{|x| x[0] * x[1]}.sum
    @max_columns = @given_seats.map{|x| x[1]}.max
  end

  def prepare_seat_arrangement
    prepare_seats_chart

    arrange_aisle_seats
    arrange_window_seats
    arrange_center_seats
  end

  def validate_given_details(args)
    msg = nil
    msg = "Invalid Input" if args.flatten.map(&:strip).all?{|arr| arr.empty?}
    msg = "Invalid seet details 1." if args.flatten[0].empty?
    msg = "Invalid passengers" if args.flatten[1].empty?
    return nil if msg
    @given_seats = JSON.parse(args.flatten[0])
    msg = "Invalid seets details 2." if @given_seats.any? { |x| !x.is_a?(Array) }
    msg = "Invalid seets format!" if @given_seats.any? { |x| x.size != 2 || x.any?{|k| k == 0} }
    @total_passenger = JSON.parse(args.flatten[1]).to_i
    return msg
  end

  def prepare_seats_chart
    rows, @sitting_arrangements = [], []
    rows = @given_seats.map{|arr| (1..arr[1]).map{Array.new(arr[0]).map{ 'N' }}}
   
    (1..@max_columns).each_with_index do |column, index|
        @sitting_arrangements << rows.map { |row| row[index] }
    end
  end

  def arrange_aisle_seats
    @aisle_seats = []
    @sitting_arrangements.each do |plane_rows|
      result = []
      plane_rows.each_with_index do |verticle, index|
        if verticle.nil?
          result << nil
        else
          if index == 0
            if verticle.size > 1
              @passengers_seated += 1
              verticle[-1] = @passengers_seated <= @total_passenger ? @passengers_seated.to_s : 'XX'
            end
          elsif index == plane_rows.size - 1
            if verticle.size > 1
              @passengers_seated += 1
              verticle[0] = @passengers_seated <= @total_passenger ? @passengers_seated.to_s : 'XX'
            end
          else
            @passengers_seated += 1
            verticle[0] = @passengers_seated <= @total_passenger ? @passengers_seated.to_s : 'XX'
            if verticle.size > 1
              @passengers_seated += 1
              verticle[-1] = @passengers_seated <= @total_passenger ? @passengers_seated.to_s : 'XX'
            end
          end
          result << verticle
        end
      end
      @aisle_seats << result
    end
  end

  def arrange_window_seats
    @window_seats = []
    @aisle_seats.each do |plane_rows|
      result = []
      plane_rows.each_with_index do |verticle, index|
        if verticle.nil?
          result << nil
        else
          if [0, plane_rows.size - 1].include?(index)
            idx = index == 0 ? 0 : -1
            @passengers_seated += 1
            verticle[idx] = @passengers_seated <= @total_passenger ? @passengers_seated.to_s : 'XX'
          end
          result << verticle
        end
      end
      @window_seats << result
    end
  end

  def arrange_center_seats
    @center_seats = []
    @window_seats.each do |plane_rows|
      result = []
      plane_rows.each_with_index do |verticle, index|
        if verticle.nil?
          result << nil
        else
          verticle.each_with_index do |x, idx|
            next if [0, verticle.size - 1].include?(idx)
            @passengers_seated += 1
            verticle[idx] = @passengers_seated <= @total_passenger ? @passengers_seated.to_s : 'XX'
          end
          result << verticle
        end
      end
      @center_seats << result
    end
  end
end


input = File.readlines('input.txt') # ["[[3,2], [4,3], [2,3], [3,4]]\n", "30"]
seating = AirlineSeatingArrangement.new(input)
result = seating.prepare_seat_arrangement

