#!/usr/bin/ruby

# Frontend to ssh that uses mcollective discovery to find hosts.
#
# It requires the highline gem to be available, basic usage is:
#
#  mc-ssh --with-class /webserver/ -- -l root
#
# This will present you with a list of hosts and run:
#    
#    ssh <host> -l root
#
# on your chosen host.
#
# Released under Apache Licence 2, R.I.Pienaar <rip@devco.net>
#
# https://github.com/puppetlabs/mcollective-plugins

require 'mcollective'
require 'highline/import'

HighLine.track_eof = false

include MCollective::RPC

options = rpcoptions do |parser, options|
  parser.define_head "MCollective discovery enabled ssh"
  parser.banner = "Usage: mc-ssh [filters and options] -- [ssh options]"
end

if ARGV.length >= 1
    sshoptions = ARGV.join(" ")
end


rpcutil = rpcclient("rpcutil", :options => options)
rpcutil.progress = false
client = rpcutil.client

# Shows a list of options and lets the user choose one
def pick(choices)
  return choices[0][1] if choices.size == 1
  keys = choices.keys

  choose do |menu|
    keys.each do |choice|
        menu.choice choice
    end

    menu.choice "Exit" do exit! end
  end
end


addresses = {}
rpcutil.get_fact(:fact => 'ipaddress') do |resp|
  begin
    value = resp[:body][:data][:value]
    addresses[resp[:senderid]] = value if value
  rescue Exception => e
    STDERR.puts "Could not parse facts for #{resp[:senderid]}: #{e.class}: #{e}"
  end
end

ip = if addresses.size == 1
  addresses.values.first
else
  hostname = pick(addresses)
  addresses[hostname]
end

begin
    puts("Running: ssh #{ip} #{sshoptions}")
    exec("ssh #{ip} #{sshoptions}")
rescue Exception => e
    puts("Failed to run mc-ssh: #{e}")
    puts e.backtrace
    exit!
end
