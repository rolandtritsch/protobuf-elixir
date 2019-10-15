defmodule Day do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          day: integer,
          month: integer,
          year: integer,
          week_day: atom | integer
        }
  defstruct [:day, :month, :year, :week_day]

  field :day, 1, type: :int64
  field :month, 2, type: :int64
  field :year, 3, type: :int64
  field :week_day, 4, type: WeekDay, enum: true
end

defmodule Event do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          when: Day.t() | nil,
          what: String.t()
        }
  defstruct [:when, :what]

  field :when, 1, type: Day
  field :what, 2, type: :string
end

defmodule WeekDay do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :MONDAY, 0
  field :TUESDAY, 1
  field :WEDNESDAY, 2
  field :THURSDAY, 3
  field :FRIDAY, 4
  field :SATURDAY, 5
  field :SUNDAY, 6
end
