defmodule ExLinguaSentence.Mixfile do
    use Mix.Project

    def project do
        [
            app: :ex_lingua_sentence,
            version: "0.1.0",
            elixir: "~> 1.3",
            build_embedded: Mix.env == :prod,
            start_permanent: Mix.env == :prod,
            deps: deps,
            package: package
        ]
    end

    def application do
        [ applications: [ :logger ] ]
    end

    defp deps do
        [
            { :exactor, "~> 2.2.2", warn_missing: false }
        ]
    end

    defp package do
        [
            files: [ "lib", "mix.exs", "README", "LICENSE*", "share" ],
            maintainers: [ "Stephen Riley" ],
            licenses: [ "GNU LESSER GENERAL PUBLIC LICENSE v3" ],
            links: %{ "GitHub" => "https://github.com/stephen-riley/ex_lingua_sentence" }
        ]
    end
end
