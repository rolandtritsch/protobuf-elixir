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

initial_case = TestHelpers.generate(1, 1)
test_case = TestHelpers.generate(25, 400)

Benchee.run(%{
    "decode initial" => fn ->  initial_case[:encoded] |> Enum.each(&Event.decode/1) end,
    "decode test" => fn ->  test_case[:encoded] |> Enum.each(&Event.decode/1) end,
  },
  memory_time: 2
)
