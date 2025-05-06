require "date"
require "dotenv/load"
require "openai"
require "mcp_client"

OPENAI_API_KEY = ENV["OPENAI_API_KEY"]

openai_client = OpenAI::Client.new(access_token: OPENAI_API_KEY)

mcp_client = MCPClient.create_client(
  mcp_server_configs: [
    MCPClient.stdio_config(
      command: %W[npx -y @modelcontextprotocol/server-filesystem #{Dir.pwd}/test]
    )
  ]
)
tools = mcp_client.to_openai_tools

print "Please enter a message: "
message = gets.chomp
messages = [
  { role: "user", content: message },
]

loop_count = 0
while loop_count < 10 do
  chat_response = openai_client.chat(
    parameters: {
      model: "gpt-4o",
      messages:,
      tools:,
    },
  )
  message = chat_response.dig("choices", 0, "message")
  pp message
  if message["role"] == "assistant" && message["tool_calls"]
    messages << message
    message["tool_calls"].each do |tool_call|
      tool_call_id = tool_call.dig("id")
      function_name = tool_call.dig("function", "name")
      function_args = JSON.parse(
        tool_call.dig("function", "arguments"),
        { symbolize_names: true },
      )

      result = mcp_client.call_tool(function_name, function_args)
      messages << {
        tool_call_id:,
        role: "tool",
        name: function_name,
        content: result.dig("content", 0, "text"),
      }
    end
  else
    break
  end

  loop_count += 1
end

puts "Finished!"
