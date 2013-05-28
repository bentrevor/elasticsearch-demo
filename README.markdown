# Elasticsearch Summary

### What is Elasticsearch?
Elasticsearch is an information retrieval libarary that stores information as JSON objects and exposes them through an HTTP API.  It is written in Java, but there are many [community-supported clients](http://www.elasticsearch.org/guide/clients/) for other languages.  It is built on top of Apache Lucene, so it is similar to Apache Solr in many ways.  Elasticsearch is distributed and supports multitenancy, making it easy to scale horizontally by adding more nodes (running instances of Elasticsearch).

Elasticsearch utilizes "sharding" to get this horizontal scalability - each "document" (a JSON object, which is analagous to a row in a relational database) is stored in a "primary shard" and 0 or more "replica shards", which can be spread across multiple nodes.  Keeping the same data in multiple locations serves two purposes: it can speed up searches, and it increases reliability (in case a node crashes).

### How does it work?
Data is either PUT or POSTed to the server as JSON objects.  The data is indexed to be easily searchable, but the original document is also saved on the server and can still be retrieved.  Elasticsearch uses a default mapping (their word for a "schema"), so it isn't necessary to specify one.  In general, Elasticsearch seems to take the Railsy approach of "convention over configuration", which means it has the same benefits/drawbacks - it is generally quicker and easier to use out-of-the-box, but more complex and powerful search functionality might require a custom-written mapping.

Each document saved to the Elasticsearch server is stored in an "index", and has a "type" and unique "id" associated with it.  For example, when using the HTTP API locally, data is stored/retrieved from the url `localhost:9200/index/type/id`.

### How can I use it from the command line?
(a more thorough explanation is on [elasticsearch's github](https://github.com/elasticsearch/elasticsearch/))

It's easiest to see how Elasticsearch works through examples.  Here are some example queries that can me made to a node from the command line (after the server has been started locally on port 9200):

An index is created automatically if it doesn't already exist.  This command creates a "twitter" index:

    curl -XPUT 'http://localhost:9200/twitter/user/kimchy' -d '{ "name" : "Shay Banon" }'

    curl -XPUT 'http://localhost:9200/twitter/tweet/1' -d '
    { 
        "user": "kimchy", 
        "postDate": "2009-11-15T13:12:00", 
        "message": "Trying out Elastic Search, so far so good?" 
    }'

    curl -XPUT 'http://localhost:9200/twitter/tweet/2' -d '
    { 
        "user": "kimchy", 
        "postDate": "2009-11-15T14:12:12", 
        "message": "Another tweet, will it be indexed?" 
    }'

Now our "twitter" index has a three documents: one of type "user" and id "kimchy", and two of type "tweet".  To retrieve these documents, we can use `curl -XGET` and point it to the correct url.

Queries can either be specified as url parameters:

    curl -XGET 'http://localhost:9200/twitter/tweet/_search?q=user:kimchy&pretty=true'

Or they can be specified as JSON objects:

    curl -XGET 'http://localhost:9200/twitter/tweet/_search?pretty=true' -d '
    { 
        "query" : { 
            "text" : { "user": "kimchy" }
        } 
    }'

We can also search the entire `twitter` index (instead of the `tweet` type):

    curl -XGET 'http://localhost:9200/twitter/_search?pretty=true' -d '
    { 
        "query" : { 
            "range" : { 
                "postDate" : { "from" : "2009-11-15T13:00:00", "to" : "2009-11-15T14:00:00" } 
            } 
        } 
    }'

Elasticsearch provides a [ton of queries](http://www.elasticsearch.org/guide/reference/query-dsl/).

### How can I use it in a Rails app?
(this is a brief summary of [this railscast](https://github.com/elasticsearch/elasticsearch/))

In short, Elasticsearch can be used in Rails apps by using the [Tire gem](https://github.com/karmi/tire), which provides a Ruby interface for Elasticsearch queries.

To use it with ActiveRecord classes, two modules need to be included:

    class Article < ActiveRecord::Base
      include Tire::Model::Search
      include Tire::Model::Callbacks

      ...
    end

The `Search` module adds searching and indexing methods, and the `Callbacks` module adds methods to update the index automatically after changes to the record.

Adding these modules doesn't add existing records to the index, so `rake db:setup` may be necessary for accurate search results.

To add the search form to the page, we can make a basic form that points to the `index` action of articles, and modify the definition of `index`:

    <%= form_tag articles_path, method: :get do %>
      <p>
        <%= text_field_tag :query, params[:query] %>
        <%= submit_tag "Search", name: nil %>
      </p>
    <% end %>

Now we need to tell the `index` method to only return certain results when `params[:query]` exists:

    def index
      if params[:query].present?
        @articles = Article.search( params[:query] )
      else
        @articles = Article.all
      end
    end

The `search` method is provided by Tire.

### Why is my search returning already-deleted articles?
When something gets indexed by Tire, it stays there until explicitly removed.  When I was testing out the search form, I kept seeing articles that were already deleted (and would give me a 404).  For this demo app, the easy solution was running a rake task to clear the index and re-seed the database: `rake tire:index:drop INDEX=articles`.  According to [this github issue](https://github.com/karmi/tire/issues/309), there is only a hacky workaround for selectively removing things from an index, so that should probably be accounted for when deciding whether or not to use Elasticsearch.

### Other options
Apache Solr is another open-source search server built on top of Apache Lucene.  [This article](http://blog.sematext.com/2012/08/23/solr-vs-elasticsearch-part-1-overview/) and [this article](http://www.ymc.ch/en/why-we-chose-solr-4-0-instead-of-elasticsearch) are good comparisons of the benefits and drawbacks of each.  From what can tell, Solr is "more powerful" but requires more configuration, and Elasticsearch is a better option for a site that needs "basic" full-text search.  But that's not to say Elasticsearch is weak or inflexible (from the YMC article):

> Our search engine should be highly available & fault tolerant. It should be in a position to manage thousands of requests per second and nevertheless the response time should be under one second. This magic should work on a few low-end servers, at the beginning. Both search engines can manage this, so it’s a tough decision for me, we need a pros & cons list.



