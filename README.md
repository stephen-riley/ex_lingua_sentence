# ExLinguaSentence

Separates a paragraph of text into sentences.  A port of the [Lingua::Sentence](http://search.cpan.org/~achimru/Lingua-Sentence-1.05/lib/Lingua/Sentence.pm) perl library.  See [here](http://cpansearch.perl.org/src/ACHIMRU/Lingua-Sentence-1.05/share/) for a list of supported languages.

## Installation

Add `ex_lingua_sentence` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:ex_lingua_sentence, "~> 0.1.1"}]
  end
  ```
## Usage

```elixir
en_splitter = ExLinguaSentence.start_link( "en" )
sentences = en_splitter.split( "The first sentence.  The second... And the third." )
```