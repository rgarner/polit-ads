##
# Take a structured directory and create or update
# AdCodeValueDescriptions from it
class AdCodeValueDescriptionsLoader
  attr_reader :dir

  ##
  # A file containing markdown and front matter
  class MarkdownFile
    attr_accessor :pathname
    def initialize(filename)
      self.pathname = Pathname.new(filename)
    end

    def campaign_slug
      pathname.parent.parent.basename.to_s
    end

    def index
      pathname.dirname.basename.to_s.to_i
    end

    def value
      pathname.basename('.md').to_s
    end

    def value_name
      front_matter.fetch('name')
    end

    def published
      front_matter.fetch('published')
    end

    def confidence
      front_matter['confidence']
    end

    def content
      @content ||= File.open(pathname, 'r').read
    end

    def front_matter
      @front_matter ||= YAML.load(content)
    end

    def content_without_front_matter
      content.sub(/---\n.*---$/m, '')
    end

    def where
      AdCodeValueDescription.joins(ad_code: :campaign).where(
        'campaigns.slug' => campaign_slug,
        'ad_codes.index' => index,
        value: value
      )
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

  ##
  # From the source +#dir+ 's +#markdown_files+ , create or update
  # AdCodeValueDescriptions
  def create_or_update
    markdown_files.each do |markdown_file|
      description = markdown_file.where.first_or_create.tap do |value_description|
        value_description.description = markdown_file.content_without_front_matter
        value_description.confidence = markdown_file.confidence
        value_description.value = markdown_file.value
        value_description.value_name = markdown_file.value_name
        value_description.published = markdown_file.published
        value_description.ad_code = AdCode.joins(:campaign).find_by!(
          'campaigns.slug' => markdown_file.campaign_slug,
          index: markdown_file.index
        )
      end

      description.save!
    end
  end
end
