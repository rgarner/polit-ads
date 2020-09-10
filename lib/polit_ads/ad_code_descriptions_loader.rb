##
# Take a structured directory and update
# AdCode#description from it
class AdCodeDescriptionsLoader
  attr_reader :dir

  ##
  # A file containing markdown and front matter
  class MarkdownFile
    attr_accessor :pathname
    def initialize(filename)
      self.pathname = Pathname.new(filename)
    end

    def campaign_slug
      pathname.parent.basename.to_s
    end

    def index
      pathname.basename('.md').to_s.to_i
    end

    def name
      front_matter.fetch('name')
    end

    def short_desc
      front_matter['short_desc']
    end

    def confidence
      front_matter['confidence']
    end

    def quality
      front_matter['quality']
    end

    def slug
      name.downcase.gsub(' ', '-')
    end

    def content
      @content ||= File.open(pathname, 'r').read
    end

    def front_matter
      @front_matter ||= YAML.load(content) || raise('No YAML found')
    end

    def content_without_front_matter
      content.sub(/---\n.*---$/m, '')
    end

    def campaign
      Campaign.find_by!(slug: campaign_slug)
    end

    def where
      AdCode.where(index: index, campaign: campaign)
    end

    def to_s
      pathname.to_s
    end
  end

  def initialize(dir)
    @dir = dir
  end

  def markdown_files
    Enumerator.new do |y|
      Dir[File.join(dir, '**/*.md')].each do |markdown_filename|
        y.yield MarkdownFile.new(markdown_filename)
      end
    end
  end

  def create_or_update
    markdown_files.each do |markdown_file|
      puts markdown_file
      markdown_file.where.first_or_create.tap do |ad_code|
        ad_code.description = markdown_file.content_without_front_matter
        ad_code.short_desc = markdown_file.short_desc
        ad_code.slug = markdown_file.slug
        ad_code.confidence = markdown_file.confidence
        ad_code.name = markdown_file.name
        ad_code.quality = markdown_file.quality

        ad_code.save!
      end

    end
  end
end
