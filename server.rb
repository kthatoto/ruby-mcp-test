require "mcp"

name "greeting-mcp-server"
version "0.1.0"

tool "greet" do
  description "A simple greeting tool"
  argument :name, String, required: true, description: "Name of the person to greet"
  call { |args| "Hello, #{args[:name]}!" }
end
