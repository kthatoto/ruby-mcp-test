require "dotenv/load"
require "openai"
require "date"

OPENAI_API_KEY = ENV["OPENAI_API_KEY"]

openai = OpenAI::Client.new(access_token: OPENAI_API_KEY)

chat_response = openai.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      { role: "system", content: "テストです" },
      { role: "user", content: "こんにちは！" }
    ],
    temperature: 0.7
  }
)

res = chat_response.dig("choices", 0, "message", "content")
pp res
