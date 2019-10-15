defmodule ProtoBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :proto_bench,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: true,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:google_protos, "~> 0.1"},
      {:protobuf, "~> 0.5"}
    ]
  end
end
