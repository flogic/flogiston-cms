class ActionView::PathSet
  def find_template_with_flogiston_layout(*args)
    if args.first.is_a?(::Layout)
      return args.first
    else
      find_template_without_flogiston_layout(*args)
    end
  end
  alias_method_chain :find_template, :flogiston_layout
end
