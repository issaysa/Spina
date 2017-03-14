module Spina
  module ApplicationHelper

    def amp_ready?
      defined?(@amp_ready) && @amp_ready == true
    end
    def amp_img(html)
      html.gsub(/<img(.+) width="(.+)" height="(.+)">/,"<amp-img#{$1} width='350' height='#{($3.to_i/($2.to_i/350)).to_s}'></amp-img>")
    end

    def current_account
      @current_account ||= Account.first
    end

    def image_tag_with_at2x(name_at_1x, options={})
      name_at_2x = name_at_1x.gsub(%r{\.\w+$}, '@2x\0')
      image_tag(name_at_1x, options.merge("data-at2x" => asset_path(name_at_2x)))
    end

    def error_explanation!(resource)
      return "" if resource.errors.empty?

      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      sentence = I18n.t("errors.messages.not_saved", count: resource.errors.count, resource: resource.class.model_name.human.downcase)

      html = <<-HTML
      <div id="error_explanation" class="notification notification-error" data-icon='m'>
        <p>#{sentence}</p>
        <ul>#{messages}</ul>
      </div>
      HTML

      html.html_safe
    end

  end
end
