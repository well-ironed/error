defmodule Error.MixProject do
  use Mix.Project

  def project do
    [
      app: :error,
      deps: deps(),
      description: description(),
      docs: docs(),
      elixir: "~> 1.9",
      package: package(),
      source_url: "https://github.com/well-ironed/error",
      start_permanent: Mix.env() == :prod,
      version: "0.3.4"
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
      {:fe, "~> 0.1.2"}
    ]
  end

  defp description do
    "Modeling errors as data"
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
