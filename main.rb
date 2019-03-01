class HashCode
  def initialize(in_file)
    @num_images
    @in_file = File.join(Dir.pwd, 'in', in_file)
    @out_file = File.join(Dir.pwd, 'out', "#{in_file.sub('.txt', '.out')}")
    @images = []
    @slides = []
    @used_ids = []
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
  end

  # GOOD
  def score_output
    score = 0

    for idx in 1..@slides.count - 1
      score += get_score_between(@slides[idx - 1], @slides[idx])
    end

    pp "Slides: #{@slides.count}"
    pp "Score: #{score}"
    score
  end

  def solve
    @slides << @images.first
    @used_ids = Array(@images.first[:id])

    for i in 0..@num_images - 1
      tags_we_want = @slides[i][:tags].select do |tag|
        (@tags[tag.to_sym] - (@used_ids | Array(@slides[i][:id]))).count >= 1
      end

      golden_tag = tags_we_want.first
      if golden_tag
        other_id = (@tags[golden_tag.to_sym] - @used_ids | Array(@slides[i][:id])).first

        # push
        @slides << @images[other_id]
        @used_ids << other_id
      else
        return
      end
    end
  end

  # GOOD
  def create_tags_map
    @images.each_with_index do |image, idx|
      image[:tags].each do |tag|
        if @tags.key?(tag.to_sym)
          @tags[tag.to_sym] << idx
        else
          @tags[tag.to_sym] = Array(idx)
        end
      end
    end
  end

  # GOOD
  def get_unique_tags(tags)
    tags.select { |tag| @tags[tag.to_sym].count == 1 }
  end

  # GOOD
  def get_non_unique_tags(tags)
    tags.reject { |tag| @tags[tag.to_sym].count == 1 }
  end

  # GOOD
  def get_images_with_unique_tags
    @images.select do |image|
      image[:tags].all? { |tag| @tags[tag.to_sym].count == 1 }
    end
  end

  # GOOD
  def write_output
    File.open(@out_file, 'w') do |f|
      f << "#{@slides.count}\n"
      @slides.each do |slide|
        f.puts "#{slide[:id]}\n"
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
