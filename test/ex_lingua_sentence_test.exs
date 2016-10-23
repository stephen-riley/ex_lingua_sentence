defmodule ExLinguaSentenceTest do
    use ExUnit.Case
    doctest ExLinguaSentence

    test "load nonbreaking prefix file for English" do
        nbp = ExLinguaSentence.load_nonbreaking_prefix_file( "en" )
        assert is_nil( nbp ) != true
    end

    test "undefined language" do
        assert ExLinguaSentence.start_link( "__" ) == { :error, "undefined language __" }
    end

    test "single word" do
        { :ok, en } = ExLinguaSentence.start_link( "en" )
        sentences = [ "Foo" ]
        res = ExLinguaSentence.split( en, Enum.join( sentences, "  " ) )
        assert Enum.count( res ) == 1
        assert res == sentences
    end

    test "single sentence" do
        { :ok, en } = ExLinguaSentence.start_link( "en" )
        sentences = [ "This is a single sentence." ]
        res = ExLinguaSentence.split( en, Enum.join( sentences, "  " ) )
        assert Enum.count( res ) == 1
        assert res == sentences        
    end

    test "multiple sentences" do
        { :ok, en } = ExLinguaSentence.start_link( "en" )
        sentences = [
            "This is the first sentence.",
            "This is the second sentence.",
            "And this is the third."
        ]
        res = ExLinguaSentence.split( en, Enum.join( sentences, "  " ) )
        assert Enum.count( res ) == 3
        assert res == sentences
    end

    test "Greek sentences" do
        { :ok, el } = ExLinguaSentence.start_link( "el" )
        res = ExLinguaSentence.split( el, "Όλα τα συστήματα ανώτατης εκπαίδευσης σχεδιάζονται σε εθνικό επίπεδο. Η ΕΕ αναλαμβάνει κυρίως να συμβάλει στη βελτίωση της συγκρισιμότητας μεταξύ των διάφορων συστημάτων και να βοηθά φοιτητές και καθηγητές να μετακινούνται με ευκολία μεταξύ των συστημάτων των κρατών μελών." )
        assert Enum.count( res ) == 2
    end

    test "odd punctuation" do
        { :ok, en } = ExLinguaSentence.start_link( "en" )
        
        [
            "Hey! Now.",
            "Hey... Now.",
            "Hey. Now.",
            "Hey.  Now."
        ]
        |> Enum.each( fn sentence ->
            res = ExLinguaSentence.split( en, sentence )
            assert Enum.count( res ) == 2
            assert List.last( res ) == "Now."
            assert String.starts_with?( List.first( res ), "Hey" )
        end )
    end
end
