module ActionController::Layout
  def find_layout_with_flogiston_layout(*args)
    if args.first.is_a?(Template)
      return args.first
    else
      find_layout_without_flogiston_layout(*args)
    end
  end
  alias_method_chain :find_layout, :flogiston_layout
end