# coding: utf-8
this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../proto')
$LOAD_PATH.unshift(this_dir) unless $LOAD_PATH.include?(this_dir)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require "hiyoco/calendar/event_pb"
require "hiyoco/filter/service_pb"
require "hiyoco/filter/service_services_pb"
require "hiyoco/informant/service_services_pb"
require "funnel"

class FilterServer < Hiyoco::Filter::Filter::Service
  def say_event(e, _unused_call)
    query = ["summary:打合せ", "hide:description", "slack"]
    funnel = Funnel.new(query)
    #funnel.outlet.apply(e) # for confirm raw event
    funnel.apply(e)
  end
end

def main
  if ARGV[0] == nil then
    host = "localhost"
  else
    host = ARGV[0]
  end
  if ARGV[1] == nil then
    port = 50050
  else
    port = ARGV[1]
  end

  s = GRPC::RpcServer.new
  s.add_http2_port("#{host}:#{port}", :this_port_is_insecure)
  s.handle(FilterServer)
  s.run_till_terminated
end

main
