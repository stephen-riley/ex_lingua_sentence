defmodule ExLinguaSentence do
    use ExActor.GenServer
    use GenServer

    @root_dir File.cwd!
    @share_dir "#{@root_dir}/share"

    def start_link( language ) do
        try do
            GenServer.start_link( __MODULE__, load_nonbreaking_prefix_file( language ) )
        rescue
            File.Error -> { :error, "undefined language #{language}" }
        end
    end

    def init( nbp ) do
        { :ok, nbp }
    end

    def load_nonbreaking_prefix_file( language ) do
        File.stream!( "#{@share_dir}/nonbreaking_prefix.#{String.downcase( language )}" )
        |> Enum.map( & String.trim_trailing &1 )
        |> Enum.filter( & ! String.match?( &1, ~r/^#/ ) )
        |> Enum.filter( & &1 != "" )
        |> Enum.map( fn line ->
            matches = Regex.named_captures( ~r/(?<tag>.*)[\s]+\#NUMERIC_ONLY\#/, line )
            case matches do
                %{ "tag" => tag } -> { tag, 2 }
                _ -> { line, 1 }
            end
        end )
        |> Map.new
    end

    defcall split( text ), state: nbp do
        preprocess( text, nbp )
        |> String.split( "\n" )
        |> reply
    end

    defp preprocess( text, nbp ) do
        text
        # non-period end of sentence markers (?!) followed by sentence starters.
        |> String.replace( ~r/([?!]) +([\'\"\(\[\¿\¡\p{Pi}]*[\p{Lu}])/, "\\1\n\\2" )
        # multi-dots followed by sentence starters
        |> String.replace( ~r/(\.[\.]+) +([\'\"\(\[\¿\¡\p{Pi}]*[\p{Lu}])/, "\\1\n\\2" )
        # add breaks for sentences that end with some sort of punctuation inside a quote or parenthetical and are followed by a possible sentence starter punctuation and upper case
        |> String.replace( ~r/([?!\.][\ ]*[\'\"\)\]\p{Pf}]+) +([\'\"\(\[\¿\¡\p{Pi}]*[\ ]*[\p{Lu}])/, "\\1\n\\2" )
        # add breaks for sentences that end with some sort of punctuation are followed by a sentence starter punctuation and upper case
        |> String.replace( ~r/([?!\.]) +([\'\"\(\[\¿\¡\p{Pi}]+[\ ]*[\p{Lu}])/, "\\1\n\\2" )
        # special punctuation cases are covered. Check all remaining periods.
        |> big_chunk( nbp )
        # clean up spaces at head and tail of each line as well as any double-spacing
        |> String.replace( ~r/ +/, " " )
        |> String.replace( ~r/\n /, "\n" )
        |> String.replace( ~r/ \n/, "\n" )
        |> String.replace( ~r/^ /, "" )
        |> String.replace( ~r/ $/, "" )
    end

    defp big_chunk( text, nbp ) do
        text
        |> String.split( ~r/ +/ )
        |> k2_reduce( "", fn word, next, acc ->
            matches = Regex.named_captures( ~r/(?<prefix>[\p{Xan}\.\-]*)([\'\"\)\]\%\p{Pf}]*)(?<starting_punct>\.+)$/, word )
            case matches do
                %{ "prefix" => prefix, "starting_punct" => starting_punct } ->
                    cond do
                        prefix != "" and nonbreaking_prefix( prefix, nbp ) == 1 and starting_punct == "" ->
                            "#{acc}#{word} "
                        String.match?( word, ~r/(\.)[\p{Lu}\-]+(\.+)$/ ) ->
                            "#{acc}#{word} "
                        String.match?( next, ~r/^([ ]*[\'\"\(\[\¿\¡\p{Pi}]*[ ]*[\p{Lu}0-9])/ ) ->
                            cond do
                                ! ( prefix != "" and nonbreaking_prefix( prefix, nbp ) == 2 && starting_punct == "" && String.match?( next, ~r/^[0-9]+/ ) ) ->
                                    "#{acc}#{word}\n"
                                true -> "#{acc}#{word} "
                            end
                        true -> "#{acc}#{word} "
                    end
                _ -> "#{acc}#{word} "
            end
        end )
    end

    defp k2_reduce( [], acc, _callback ), do: acc
    defp k2_reduce( [ h ], acc, callback ), do: k2_reduce( [], callback.( h, "", acc ), callback )
    defp k2_reduce( [ h | rest ], acc, callback ) do
        k2_reduce( rest, callback.( h, List.first( rest ), acc ), callback )
    end

    defp nonbreaking_prefix( prefix, nbp ) do
        case Map.fetch( nbp, prefix ) do
            { :ok, res } -> res
            :error -> 0
        end
    end
end