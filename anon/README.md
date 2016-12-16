Anon
====

### A discussion of a foundation toolset for building modern Internet applications with the elixir language.

> Don't love your tools. Love what they let you do.

## Discussion Driven Development
**This is not a framework developed in private I hope to release with fanfair**. To do so would fill the project with failings and inconsistencies by limiting it to a few points of view. Instead this project aims to expose the decision making process from day 1.

Currently the project only consists of this README and issues.

A lot of the thinking has been driven by completing this blog series on [domain driven design in Ruby](http://insights.workshop14.io/2015/07/14/domain-driven-design-introduction.html). Domain driven design asserts that a framework should be offer service to an application and not dictate how the application is arranged.

Finally many current framework solutions seam stuck in web 2.0 thinking with websockets added after. To handle both two way communication and offline modes something other than CRUD/REST is needed.

## Components

- [raxx](https://github.com/CrowdHailer/raxx/) web interface for elixir
- gutenberg templates for html etc
- heimdall form validation
- Pachyderm event sourced aggregates

## Inspiration
Tech always moves fast, such thing as the [NoSQL](http://martinfowler.com/bliki/NosqlDefinition.html) movement and the recent [churn in javascript frameworks](http://confreaks.tv/videos/lonestarruby2015-surviving-the-framework-hype-cycle) are challenging many assumptions. The list bellow are some of the ideas that are most relevant to where this project is going to begin with. 

- **[DDD](http://insights.workshop14.io/2015/08/20/domain-driven-design-where-the-real-value-lies.html)** use domain relevant messages for communication
- **[Datomic](http://www.datomic.com/)** record changes not state to preserve history
- **[MQTT](http://www.hivemq.com/mqtt-essentials-part-1-introducing-mqtt/)** communication in realtime when relevant
- **[baconjs](https://baconjs.github.io/)/[ReactiveX](http://reactivex.io/)/[kefirjs](https://github.com/rpominov/kefir)** first class support async events and updates
- **[Rack](http://rack.github.io/)** use a request/response abstraction not a connection one for requests and responses.
- **[ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html)** unified view of task
- **[t3js](http://t3js.org/)** flexible and extensible core structure
- **[hoodie](http://hood.ie/)** sensible offline contingency

## Aims
- Encourage contributors  
  Gather as many points of view as possible to build robust abstractions.
- To not build a framework  
  We may end up very near a framework but as much as possible this setup should be called by an application and not the other way round.
- Elixir as much as possible  
  The language choice is not the most important thing here, however Elixir developers should as rarely as possible need to use erlang to contribute. 
- Simple things still simple  
  Example, realtime concerns must not add any complexity to thinking about a  request/response interaction.
- New capabilities not new conventions  
  Websockets add completly new capabilities to the web experience, transpiled ES6 does not. We will focus on the former.

# Let's get started
- Simple request/response abstraction is my issue [#1](https://github.com/workshop14/anon/issues/1)  
  [reddit descussion](https://www.reddit.com/r/ruby/comments/3jlpdo/where_is_rack_next_and_a_possible_elixir_successor/)
- Extend first class events into the client and into the database
  - [flight.js]() has some ideas for passing events in the client
  - [Datomic for 5yr olds](http://www.flyingmachinestudios.com/programming/datomic-for-five-year-olds/) has links to the datomic information model and the unofficial guide to rich hickeys brain

## Realtime messaging
The MQTT protocol seams the best way to send events particularly with websocket bridges. [CloudMQTT](https://www.cloudmqtt.com/) is a hosted mqtt broker with a free tier. [HiveMQ](http://www.hivemq.com/) is a program to download with a free license that allows less than 25 connections for personal projects.

[Paho](http://www.eclipse.org/paho/) is a selection of client libraries but does not include Ruby or Elixir
  

# Contributing
 You're encouraged to submit pull requests, propose features and discuss issues.

[Advice on encouraging contributions](http://confreaks.tv/videos/gogaruco2014-taking-over-someone-else-s-open-source-projects)
