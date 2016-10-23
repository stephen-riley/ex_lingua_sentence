defmodule ExLinguaSentence do
    use Application

    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        # Define workers and child supervisors to be supervised
        children = [
            worker( ExLinguaSentence.Worker, ["en"] ),
        ]

        opts = [strategy: :one_for_one, name: ExLinguaSentence.Supervisor]
        Supervisor.start_link(children, opts)
    end
end
