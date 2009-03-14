class Page
  generator_for :handle, :start => 'test_handle_000001' do |prev|
    prev.succ
  end
end
