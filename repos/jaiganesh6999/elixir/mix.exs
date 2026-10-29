defmodule SeoWebChecker.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/tree/main/elixir"
  @homepage_url "https://seowebchecker.com/"

  def project do
    [
      app: :seowebchecker,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Automated on-page technical SEO diagnostic engine and client SDK for meta tag validations, heading structure inspections, and Core Web Vitals checks. Powered by SEOWebChecker (https://seowebchecker.com/)."
  end

  defp package do
    [
      name: "seowebchecker",
      maintainers: ["Rahul Gupta <jaiganesh6999@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "Homepage" => @homepage_url,
        "GitHub" => @source_url,
        "SEO Audit Tool" => @homepage_url
      },
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end

  defp docs do
    [
      main: "SeoWebChecker",
      source_url: @source_url,
      homepage_url: @homepage_url
    ]
  end
end
