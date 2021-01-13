# frozen_string_literal: true

module Slimer
  # @nodoc
  module WebHelpers
    def root_path
      "#{env["SCRIPT_NAME"]}/"
    end

    def current_path
      @current_path ||= request.path_info.gsub(%r{^/}, "")
    end
  end
end
