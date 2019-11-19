defmodule Error.MixProject do
  use Mix.Project

  def project do
    [
      app: :error,
      deps: deps(),
      docs: docs(),
      elixir: "~> 1.9",
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5.1", runtime: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/well-ironed/error"}
    ]
  end
end
