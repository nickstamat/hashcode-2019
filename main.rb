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
    score_output
    write_output
  end

  # GOOD
  def parse_input
    File.readlines(@in_file).each_with_index do |line, idx|
      if idx == 0
        @num_images = line.strip.to_i
        next
      end

      image = line.strip.split
      @images << { id: idx - 1, orientation: image.first, tags: image.drop(2) }
    end
    @used_map = Array.new(@num_images) { |i| false }
  end

  # GOOD
  def score_output
    puts("Validating result...")
    slides_unique = @slides.uniq
    is_invalid = (@slides.length != slides_unique.length) || (@slides & slides_unique != @slides)

    if is_invalid
      puts("INVALID: Result contains duplicates.")
      exit
    end

    puts("Result is VALID! Calculating score...")
    score = 0

    for idx in 1..@slides.count - 1
      score += get_score_between(@slides[idx - 1], @slides[idx])
    end

    pp "Slides: #{@slides.count}"
    pp "Score: #{score}"
    score
  end

  def solve
    puts("Solving...")

    # start with the first image
    @slides << @images[0]
    @used_map[0] = true

    for i in 0..@num_images - 2
      # just a progress indicator to see where we are at
      i % 1000 == 0 && puts(i)

      found_id = maybe_get_next_id(i)
      found_id ||= @used_map.find_index(false)

      @slides << @images[found_id]
      @used_map[found_id] = true
    end
  end

  def maybe_get_next_id(i)
    @slides[i][:tags].each do |tag|
      found_id = @tags[tag].detect { |id| id != @slides[i][:id] && @used_map[id] == false }
      if found_id
        return found_id
      end
    end
    nil
  end

  # GOOD
  def create_tags_map
    puts("Creating tag map...")
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

  # GOOD
  def get_unique_tags(tags)
    tags.select { |tag| @tags[tag].count == 1 }
  end

  # GOOD
  def get_non_unique_tags(tags)
    tags.reject { |tag| @tags[tag].count == 1 }
  end

  # GOOD
  def get_images_with_unique_tags
    @images.select do |image|
      image[:tags].all? { |tag| @tags[tag].count == 1 }
    end
  end

  # GOOD
  def write_output
    puts("Writing to file...")
    File.open(@out_file, 'w') do |f|
      f << "#{@slides.count}\n"
      @slides.each do |slide|
        f.puts("#{slide[:id]}\n")
      end
    end
  end

  # GOOD
  def get_score_between(slide1, slide2)
    num_common = (slide1[:tags] & slide2[:tags]).count
    num_excl1 = (slide1[:tags] - slide2[:tags]).count
    num_excl2 = (slide2[:tags] - slide1[:tags]).count

    [num_common, num_excl1, num_excl2].min
  end
end
