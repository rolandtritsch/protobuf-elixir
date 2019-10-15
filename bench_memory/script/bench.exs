event = Event.new(
  when: Day.new(
    day: 01,
    month: 01,
    year: 1970,
    week_day: :MONDAY
  ),
  what: "hiking"
)
IO.puts("event: #{:erts_debug.size(event)}")

event_encoded = Event.encode(event)
IO.puts("event_encoded: #{:erts_debug.size(event_encoded)}")

event_decoded = Event.decode(event_encoded)
IO.puts("event_decoded: #{:erts_debug.size(event_decoded)}")
IO.puts("")

events_decoded = 1..10_000 |> Enum.map(fn _ -> event_decoded end)
events_encoded = 1..10_000 |> Enum.map(fn _ -> event_encoded end)

Benchee.run(%{
    "encode" => fn ->  [event_decoded] |> Enum.each(&Event.encode/1) end,
    "decode" => fn ->  [event_encoded] |> Enum.each(&Event.decode/1) end,
    "encode 10_000" => fn ->  events_decoded |> Enum.each(&Event.encode/1) end,
    "decode 10_000" => fn ->  events_encoded |> Enum.each(&Event.decode/1) end
  },
  memory_time: 2
)
