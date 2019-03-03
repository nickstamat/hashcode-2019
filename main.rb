require 'benchmark'

class HashCode
  def initialize(in_file)
    @num_images
    @in_file = File.join(Dir.pwd, 'in', in_file)
    @out_file = File.join(Dir.pwd, 'out', "#{in_file.sub('.txt', '.out')}")
    @images = []
    @slides = []
    @used_map = []
    @tags = {}
  end

  def run
    parse_input
    create_tags_map

    solve

    validate_output
    score_output
    write_output
  end

  def parse_input
    File.readlines(@in_file).each_with_index do |line, idx|
      if idx == 0
        @num_images = line.strip.to_i
        next
      end

      image = line.strip.split
      @images << { id: idx - 1, orientation: image.first, tags: image.drop(2) }
    end

    # initialize an array to lookup for used images
    @used_map = Array.new(@num_images) { |i| false }
  end

  def solve
    puts("Solving...")

    # start with the first image
    @slides << @images[0]
    @used_map[0] = true

    # we need to append (num_images - 1) images
    for i in 0..@num_images - 2

      # just a dumb progress indicator to see where we are
      i % 1000 == 0 && puts(i)

      # try to find next id according to tags
      found_id = find_next(i)
      # if not found, set to first unused image
      found_id ||= @used_map.find_index(false)

      # push
      @slides << @images[found_id]
      @used_map[found_id] = true
    end
  end

  def find_next(i)
    @slides[i][:tags].each do |tag|
      found_id = @tags[tag].detect { |id| id != @slides[i][:id] && @used_map[id] == false }
      if found_id
        return found_id
      end
    end
    nil
  end

  def create_tags_map
    puts("Mapping ids to tags...")
    @images.each_with_index do |image, id|
      image[:tags].each do |tag|
        if @tags.key?(tag)
          @tags[tag] << id.to_i
        else
          @tags[tag] = Array(id.to_i)
        end
      end
    end
  end

  def validate_output
    puts "Validating result..."
    slides_unique = @slides.uniq
    is_invalid = (@slides.length != slides_unique.length) || (@slides & slides_unique != @slides)

    if is_invalid
      puts "INVALID: Result contains duplicates."
      exit
    end

    # TODO: add checks for vertical image pairs

    puts "Result is VALID!"
  end

  def score_output
    puts "Calculating score..."
    score = 0

    for i in 1..@slides.count - 1
      score += get_score_between(@slides[i - 1], @slides[i])
    end

    puts "Slides: #{@slides.count}"
    puts "Score: #{score}"
    score
  end

  def write_output
    puts("Writing to file...")
    File.open(@out_file, 'w') do |f|
      f << "#{@slides.count}\n"
      @slides.each do |slide|
        f.puts("#{slide[:id]}\n")
      end
    end
  end

  def get_score_between(slide1, slide2)
    num_common = (slide1[:tags] & slide2[:tags]).count
    num_excl1 = (slide1[:tags] - slide2[:tags]).count
    num_excl2 = (slide2[:tags] - slide1[:tags]).count

    [num_common, num_excl1, num_excl2].min
  end
end
