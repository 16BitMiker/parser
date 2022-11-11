# Miker::Parser v0.1

This was inspired by the the built in ruby gem called **StringScanner**. 

## How It Works?

- **my $parser = &initParse($text_to_parse)** - Initialize parser and save data to $parser.

- **&lookAhead($parser, $regex)** - Look ahead for capturing multiple instances. Intended for use in while loops. 

- **&skipUntil ($parser, $regex)** - Skip until regex is reached. Used to advance the scan without capturing the match. 

- **&saveUntil ($parser, $regex ,q|label|)** - Save the segment to hash. Uses label as key value.

- **&insertDiv ($parser)** - Insert a divider. Signifies end of instance. Best used as last statment the while loop.

- **my $results = &returnMatches ($parser)** - Returns only the labeled matches as an array with hash of captured items.

## Demo Files

- **Parse-Geek-Social.pl** - Parses the latest news posts on https://geekalicious.social and prints out a json  construct of the results
- **Parse-Odysee-Miker-Media.pl** - Parses my odysee channel for videos and outputs as JSON.
- **Parse-Star-Control-2-Wiki.pl** - Parses and downloads .mod / .mp3 files from a Star Control II wiki.
