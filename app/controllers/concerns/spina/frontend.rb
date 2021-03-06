module Spina
  module Frontend
    extend ActiveSupport::Concern

    included do
      before_action :set_locale
      before_action :rewrite_page, only: [:show]
    end

    def show
      if should_skip_to_first_child?
        redirect_to first_live_child.try(:materialized_path) and return
      elsif page.link_url.present?
        redirect_to page.link_url and return
      end
      ActiveRecord::Base.connection.execute("update spina_page_translations set view_count = #{page.view_count+1} where spina_page_id = #{page.id}")
      if page.view_template == 'show'
        respond_to do |format|
          format.html
          @amp_ready = true
          format.amp do
            lookup_context.formats = [:amp, :html] # .htmlのテンプレートも検索する
          end
        end
      end
      render_with_template(page)
    end

    private

      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end

      def rewrite_page
        if page.nil? && rule = RewriteRule.find_by(old_path: "/" + params[:id])
          redirect_to rule.new_path, status: :moved_permanently
        end
      end

      def page_by_locale(locale)
        Page.with_translations(locale).find_by!(materialized_path: spina_request_path)
      end

      def page
        current_page = page_by_locale(I18n.locale) || page_by_locale(I18n.default_locale)
        @page ||= (action_name == 'top') ? Page.find_by!(name: 'top') : current_page
      end

      def spina_request_path
        segments = ['/', params[:locale], params[:id]].compact
        File.join(*segments)
      end

      def should_skip_to_first_child?
        page.skip_to_first_child && first_live_child
      end

      def first_live_child
        page.children.sorted.live.first
      end

      def render_with_template(page)
        if request.smart_phone?
          layout_template = (page.layout_template || "application")
          view_template = (page.view_template || "show")
          layout_template = lookup_context.exists?(layout_template+"_smart_phone",current_theme.name.parameterize.underscore) ? layout_template+"_smart_phone" : layout_template
          view_template = lookup_context.exists?(view_template+"_smart_phone",current_theme.name.parameterize.underscore+"/pages") ? view_template+"_smart_phone" : view_template
          render layout: "#{current_theme.name.parameterize.underscore}/#{layout_template}", template: "#{current_theme.name.parameterize.underscore}/pages/#{view_template}"
        else
          render layout: "#{current_theme.name.parameterize.underscore}/#{page.layout_template || 'application'}", template: "#{current_theme.name.parameterize.underscore}/pages/#{page.view_template || 'show'}"
        end
      end

  end
end
