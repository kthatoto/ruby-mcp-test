require "date"
require "dotenv/load"
require "openai"
require "mcp_client"
require "mcp"

OPENAI_API_KEY = ENV["OPENAI_API_KEY"]

openai_client = OpenAI::Client.new(access_token: OPENAI_API_KEY)

mcp_client = MCPClient.create_client(
  mcp_server_configs: [
    MCPClient.stdio_config(
      command: %W[ruby server.rb],
    )
  ]
)
tools = mcp_client.to_openai_tools

print "Please enter a message: "
message = gets.chomp
messages = [{ role: "user", content: message }]

loop_count = 0
while loop_count < 10 do
  puts "========================="
  pp messages
  chat_response = openai_client.chat(
    parameters: {
      model: "gpt-4o",
      messages:,
      tools:,
    },
  )
  message = chat_response.dig("choices", 0, "message")
  messages << message
  if message["role"] == "assistant" && message["tool_calls"]
    message["tool_calls"].each do |tool_call|
      tool_call_id = tool_call.dig("id")
      function_name = tool_call.dig("function", "name")
      function_args = JSON.parse(
        tool_call.dig("function", "arguments"),
        { symbolize_names: true },
      )

      puts "Calling tool: #{function_name}, args: #{function_args}"

      result = mcp_client.call_tool(function_name, function_args)
      messages << {
        tool_call_id:,
        role: "tool",
        name: function_name,
        content: result.dig("content", 0, "text"),
      }
    end
  else
    loop_count = 0
    puts
    puts "Assistant: #{message["content"]}"
    print "Please enter a message: "
    message = gets.chomp
    messages << { role: "user", content: message }
  end

  puts

  loop_count += 1
end

puts "Finished!"
