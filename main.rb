require "date"
require "dotenv/load"
require "openai"
require "mcp_client"

OPENAI_API_KEY = ENV["OPENAI_API_KEY"]

mcp_client = MCPClient.create_client(
  mcp_server_configs: [
    MCPClient.stdio_config(
      command: %W[npx -y @modelcontextprotocol/server-filesystem #{Dir.pwd}/test]
    )
  ]
)
tools = mcp_client.to_openai_tools

openai_client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
chat_response = openai_client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      { role: "user", content: "こんにちは！1~10の名前でテキストファイルを作成してください" }
    ],
    tools: tools,
  },
)
