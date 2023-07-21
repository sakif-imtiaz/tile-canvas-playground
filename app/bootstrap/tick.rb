# $services_before = [Services.mouse]
# $services_after = [Services.primitive_buffer]
$my_app = App.new

def tick args
  # $services_before.each { |service| service.tick(args) } unless args.state.tick_count == 0
  $my_app.perform_tick(args)
  # $services_after.each { |service| service.tick(args) }
end