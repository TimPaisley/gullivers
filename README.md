# Gulliver's Guide to Wellington

> Every city is full of **undiscovered experiences** and **unseen vistas** eagerly awaiting a new group of ambitious explorers. Your city is waiting to be explored, and Gulliver's Guide can help.

At the moment, Gulliver's Guide is still in development - that means it's not quite ready to be used yet. We're hoping to get an early version ready for user testing soon, then we plan to launch a Beta test to a wider audience.

If you have any feedback or questions, please feel free to get in contact with me - either [by email](mailto:tepaisley@gmail.com) or on Twitter [@TimPaisley](https://twitter.com/timpaisley).

## What is Gulliver's Guide?

This project provides a template for cities, councils and communities to create their very own geo-location game (kinda like Pokémon Go). The Guide consists of _Adventures_, which represent a geographically conjoined experience or group of thematically linked places in the city. Each Adventure consists of between three and seven _Locations_ - to complete an Adventure, all Locations must be visited.

Once adventurers (users) are logged in, they're presented with a list of Adventures available in their city, which might be a walking track, a set of interesting heritage points throughout the city center, or even different city events. Clicking on an Adventure will present them with a number of locations and a map to help them find their way. Once the adventurer arrives at a location, they'll hit a button in the app to register their location. When all Locations in an Adventure have been visited, that Adventure is considered complete.

Beyond _Adventures_ and _Locations_, the concepts get a little bit fuzzier. We have a lot of ideas, but it'll likely be unclear what direction we should go in until we've done some testing. Here are some cool things we're considering.

### Adventure Types
I've already mentioned that Adventures could be walking tracks or just locations that are thematically similar (e.g. cultural or heritage locations), but what about other variations?
- _Treasure Hunts_ could begin with only one location, and further locations in the Adventure could be revealed only after the previous one is completed.
- _Special Event Adventures_ could only stick around for a week or two during a particular event in the city, making them more valuable and encouraging adventurers to get out and about during the event.
- _Image Hunts_ could provide only pictures of the location (instead of a geolocation), so the adventurers would have to decipher where the location was based on landmarks.

### Quick Questions
Providing a way for adventurers to give immediate feedback to the council or community who runs the Guide would provide some really interesting interactions and insight.

### Gulliver's Graphs
In addition to feedback, using the data that we gather from adventurers could feed an open and anonymised platform that shows further insight and movement throughout the city. We could answer questions such as:

- _How many people are playing?_
- _What adventures do people like the most?_
- _During what time of the day are people adventuring?_

### Achievements
To encourage players to stick with the game for longer and more consistently, we could introduce achievements that provide long-term goals. Achievements could include:

- Complete three Adventures in a week
- Visit Locations from six different Adventures
- Visit a different Location each day for a week

### Adventure Sets
At the moment, either Adventures are differentiated by their characteristics (such as accessibility or difficult), but not by the time of their release. To maintain public interest over a longer period of time, the council or community running the Guide could release _sets_ of Adventures that share a common theme, season, or other characteristic.

## How much will Gulliver's Guide cost?

One of the goals of this project is to help people all around the world explore their beautiful cities, regardless of size or financial wellbeing.

For that reason, Gulliver's Guide is and will always be **free and open source**, no strings attached.

## How does Gulliver's Guide work?

The project is being written in [Ruby on Rails](https://rubyonrails.org/), which handles the API and [authentication](https://github.com/plataformatec/devise). After authentication, Rails serves a single-page app written in [Elm](https://elm-lang.org/). We're using a [PostgreSQL](https://www.postgresql.org/) database, together with the [PostGIS](https://postgis.net/) extension.

## When will Gulliver's Guide be ready?

Honestly... no clue. That will probably depend on how much time we can invest in the project going forward. If you're particularly invested in the future of this project, please get in touch and let us know. We're more likely to work faster if we know it's going to be valuable to someone.