defmodule TestHelpers do
  def generate(size) when size <= 0, do: []
  def generate(size), do: [Randomizer.generate!(100) | TestHelpers.generate(size - 1)]

  def build_event(size) do
    Event.new(
      when: Day.new(
        day: 01,
        month: 01,
        year: 1970,
        week_day: :MONDAY
      ),
      what: TestHelpers.generate(size)
    )
  end

  def generate(event_size, event_number) do
    events = 1..event_number |> Enum.reduce([], fn _, events ->
      [TestHelpers.build_event(event_size) | events]
    end)
    IO.puts("#{event_size}/#{event_number} - event: #{:erts_debug.flat_size(events |> hd()) * 8}")

    events_encoded = events |> Enum.map(&Event.encode/1)
    IO.puts("#{event_size}/#{event_number} - event_encoded: #{:erts_debug.flat_size(events_encoded |> hd()) * 8}")

    events_decoded = events_encoded |> Enum.map(&Event.decode/1)
    IO.puts("#{event_size}/#{event_number} - event_decoded: #{:erts_debug.flat_size(events_decoded |> hd()) * 8}")

    IO.puts("#{event_size}/#{event_number} - events_encoded: #{:erts_debug.flat_size(events_encoded) * 8}")
    IO.puts("#{event_size}/#{event_number} - events_decoded: #{:erts_debug.flat_size(events_decoded) * 8}")
    IO.puts("")


    %{encoded: events_encoded, decoded: events_decoded}
  end
end

one_one = TestHelpers.generate(1, 1)
one_ten = TestHelpers.generate(1, 10)
ten_one = TestHelpers.generate(40, 1)
ten_ten = TestHelpers.generate(40, 10)

hundred_one = TestHelpers.generate(400, 1)
thousand_one = TestHelpers.generate(4000, 1)

one_hundred = TestHelpers.generate(1, 100)
one_thousand = TestHelpers.generate(1, 1000)

Benchee.run(%{
    "encode 1-1" => fn ->  one_one[:decoded] |> Enum.each(&Event.encode/1) end,
    "encode 1-10 " => fn ->  one_ten[:decoded] |> Enum.each(&Event.encode/1) end,
    "encode 10-1" => fn ->  ten_one[:decoded] |> Enum.each(&Event.encode/1) end,
    "encode 10-10" => fn ->  ten_ten[:decoded] |> Enum.each(&Event.encode/1) end
  },
  memory_time: 2
)

Benchee.run(%{
    "decode 1-1" => fn ->  one_one[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 1-10" => fn ->  one_ten[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 10-1" => fn ->  ten_one[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 10-10" => fn ->  ten_ten[:encoded] |> Enum.each(&Event.decode/1) end
  },
  memory_time: 2
)

Benchee.run(%{
    "decode 1-1" => fn ->  one_one[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 10-1" => fn ->  ten_one[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 100-1" => fn ->  hundred_one[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 1000-1" => fn ->  thousand_one[:encoded] |> Enum.each(&Event.decode/1) end
  },
  memory_time: 2
)

Benchee.run(%{
    "decode 1-1" => fn ->  one_one[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 1-10" => fn ->  one_ten[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 1-100" => fn ->  one_hundred[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode 1-1000" => fn ->  one_thousand[:encoded] |> Enum.each(&Event.decode/1) end
  },
  memory_time: 2
)
