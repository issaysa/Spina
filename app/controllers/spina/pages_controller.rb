module Spina
  class PagesController < Spina::ApplicationController
    include Spina::Frontend

    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from Exception, with: :render_500

    before_action :current_user_can_view_page?, except: [:robots]

    helper_method :page

    def homepage
      render_with_template(page)
    end

    private

      def current_user_can_view_page?
        raise ActiveRecord::RecordNotFound if page.nil? || !page.live?

        current_user.present?
      end

      def render_404(e=nil)
        logger.info "Rendering 404 with exception: #{e.message}" if e
        file = request.smart_phone? ? "404sp.html" : "404.html"
        render file: "#{Rails.root}/public/"+file, status: 404
      end

      def render_500(e=nil)
        logger.error "Rendering 500 with exception: #{e.message}" if e
        file = request.smart_phone? ? "500sp.html" : "500.html"
        render file: "#{Rails.root}/public/"+file, status: 404
      end

  end
end
