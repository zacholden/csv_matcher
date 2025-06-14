# CSV Matching

A Ruby library for matching and processing CSV data based on configurable matching criteria.

## Improvements
- I have decomposed the main CSVMatcher class into several smaller classes based on their responsibilities.
- Algo wraps the text input of the algorithm
- Extractor deals with pulling data out of the target csv and normalizing in
- MatchingType matches the normalized inputs
- CSVWriter writes the output to to the file system

## Installation

This is a standalone Ruby application that requires no gems beyond the standard library. I used MiniTest for testing. I have used Ruby 3.4.2

## Usage

The library provides two main classes has an entry point via a CLI

Example:
`ruby csv_matcher.rb -f input1.csv -a email,phone`

## Testing

The project uses Minitest for testing. Tests are located in the `test` directory.

### Running tests

Run all tests:

```bash
rake test
```
