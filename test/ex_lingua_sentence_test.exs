defmodule ExLinguaSentenceTest do
    use ExUnit.Case
    doctest ExLinguaSentence

    test "load nonbreaking prefix file for English" do
        nbp = ExLinguaSentence.Worker.load_nonbreaking_prefix_file( "en" )
        assert is_nil( nbp ) != true
    end

    test "single word" do
        sentences = [ "Foo" ]
        res = ExLinguaSentence.Worker.split( Enum.join( sentences, "  " ) )
        assert Enum.count( res ) == 1
        assert res == sentences
    end

    test "single sentence" do
        sentences = [ "This is a single sentence." ]
        res = ExLinguaSentence.Worker.split( Enum.join( sentences, "  " ) )
        assert Enum.count( res ) == 1
        assert res == sentences        
    end

    test "multiple sentences" do
        sentences = [
            "This is the first sentence.",
            "This is the second sentence.",
            "And this is the third"
        ]
        res = ExLinguaSentence.Worker.split( Enum.join( sentences, "  " ) )
        assert Enum.count( res ) == 3
        assert res == sentences
    end
end
