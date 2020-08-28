module ValuesHelper
  CONFIDENCE_BADGES = {
    'low' => 'badge-danger',
    'medium' => 'badge-warning',
    'high' => 'badge-success'
  }.freeze

  def confidence_badge(confidence)
    tag.span class: "badge #{CONFIDENCE_BADGES[confidence]}" do
      confidence
    end
  end
end
