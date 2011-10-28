module Flogiston::DynamicLayout
  def self.extended(b)
    b.send(:class_eval) do
      layout :determine_dynamic_layout

      private

      def determine_dynamic_layout
        Layout.default || 'application'
      end
    end
  end
end

ApplicationController.extend Flogiston::DynamicLayout
