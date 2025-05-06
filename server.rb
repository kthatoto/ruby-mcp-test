require "mcp"

name "dice-mcp-server"
version "0.1.0"

tool "roll-dice" do
  description "サイコロを降ります"
  argument :sides, Integer, required: false, description: "The number of sides on the dice"
  call do |args|
    sides = args[:sides] || 6
    result = rand(1..sides)
    {
      content: [
        {
          text: "You rolled a #{result} on a #{sides}-sided dice.",
        },
      ],
    }
  end
end
