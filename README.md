# CSV Matching

A Ruby library for matching and processing CSV data based on configurable matching criteria.

## Rationale
- I wanted a flexible top level API where a user could input any number of columns
and matched based on them. My hope was to run in linear time (see below).

## Improvements
- I realized in writing tests for the second input csv there is a bug in this program. If the identifier is working off of multiple clauses it depends on the order to identify the rows correctly which does not work. Fixing this would require running every row against every other row or implementing a smarter algorithm.

## Installation

This is a standalone Ruby application that requires no gems beyond the standard library. I used MiniTest for testing. I have used Ruby 3.4.2

## Usage

The library provides two main classes:
- `MatchingType`: Define matching criteria and normalization rules
- `CSVMatcher`: Process CSV files using the defined matching rules

Example:

```ruby
# Define normalizers
normalize_email = -> (email) { email.downcase }
normalize_phone = -> (phone) { phone.to_s.gsub(/\D/, '') }

# Create matching rules
matching_type = MatchingType.new("Email and Phone")
                .match("Email", normalize: normalize_email)
                .match("Phone", normalize: normalize_phone)

# Process a CSV file
CSVMatcher.call("input.csv", matching_type, write: true)
# This creates input-matched.csv with IDs assigned
```

## Testing

The project uses Minitest for testing. Tests are located in the `test` directory.

### Running tests

Run all tests:

```bash
rake test
```
