# Sitemaps

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/manuel-rubio/sitemaps/elixir.yml)

Generating sitemap files.

## Installation

Add the sitemap library to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:sitemaps, "~> 1.2"}]
  end
  ```

### Usage

sitemap helps you define a module with a `generate` function that will build a sitemap for your site. You must decide how to call `generate` - via a manual Mix task, a recurring background job, or whatever you choose.

The resulting sitemap is written to a file.

#### Basic

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps

  def generate do
    create do
      # list each URL that should be included
      add "path1", priority: 0.5, changefreq: "hourly", expires: nil, mobile: true
      # ...
    end

    # notify search engines (currently Google and Bing) of the updated sitemap
    ping()
  end
end
```

#### With Phoenix

```elixir
defmodule MyAppWeb.Sitemaps do
  alias MyAppWeb.{Endpoint, Router.Helpers}

  use Sitemaps,
    host: "http://#{Application.get_env(:myapp, Endpoint)[:url][:host]}",
    files_path: "priv/static/sitemaps/",
    public_path: "sitemaps/"

  def generate do
    create do
      # list each URL that should be included, using your application's routes
      add Helpers.entry_path(Endpoint, :index), priority: 0.5, changefreq: "hourly", expires: nil
      add Helpers.entry_path(Endpoint, :about), priority: 0.5, changefreq: "hourly", expires: nil
      # ...
    end

    # notify search engines (currently Google and Bing) of the updated sitemap
    ping()
  end
end
```

### Ways to set sitemap's options

#### Set options via the `use` statement

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: false, host: "http://example.com"

  def generate do
    create do
      add "path1", priority: 0.5, changefreq: "hourly"
      add "path2", priority: 0.5, changefreq: "hourly"
    end

    ping()
  end
end
```

#### Set options via arguments to `create`

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps

  def generate do
    create compress: false, host: "http://example.com" do
      add "path1", priority: 0.5, changefreq: "hourly"
      add "path2", priority: 0.5, changefreq: "hourly"
    end

    ping()
  end
end
```

#### Set options via `Config` config

```elixir
import Config

config :sitemaps, [
  compress: false,
  host: "http://example.com",
]

```

#### Set options via environment variables

```elixir
SITEMAPS_COMPRESS=false SITEMAPS_HOST=http://example.com mix sitemaps
```

##### Available options

| Name                  | Default Value          | Environment           | -    |
|:----------------------|:-----------------------|:----------------------|:-----|
| max_sitemap_files     | 10000                  | SITEMAPS_MAXFILES      | Max sitemap links per index file |
| max_sitemap_links     | 10000                  | SITEMAPS_MAXLINKS      | Max links per sitemap  |
| max_sitemap_news      | 1000                   | SITEMAPS_MAXNEWS       | Max news sitemap per index_file  |
| max_sitemap_images    | 1000                   | SITEMAPS_MAXIMAGES     | Max images per url  |
| max_sitemap_file_size | 5000000                | SITEMAPS_MAXFILESIZE   | Bytes |
| host                  | http://www.example.com | SITEMAPS_HOST          | Your domain, also host with http scheme.  |
| filename              | sitemap                | SITEMAPS_FILENAME      | Name of sitemap file.  |
| files_path            | sitemap                | SITEMAPS_SITEMAPS_PATH | After domain path's location on URL.  |
| public_path           | sitemap                | SITEMAPS_PUBLIC_PATH   | Write sitemap files to this local path.  |
| verbose               | true                   | SITEMAPS_VERBOSE       | Getting more information in sitemap working.  |
| compress              | true                   | SITEMAPS_COMPRESS      | Gzip compression.  |
| create_index          | auto                   | SITEMAPS_CREATE_INDEX  | Generating sitemaps to this directory path.  |

### Features

Current Features or To-Do

- [x] [Supports: generate kind of some sitemaps](#supports-generate-kind-of-some-sitemaps)
  - [x] [News Sitemaps](#news-sitemaps)
  - [x] [Image Sitemaps](#image-sitemaps)
  - [x] [Video Sitemaps](#video-sitemaps)
  - [x] [Alternate Links](#alternate-links)
  - [x] [Geo Sitemaps](#geo-sitemaps)
  - [x] [Mobile Sitemaps](#mobile-sitemaps)
  - [x] [PageMap Sitemap](#pagemap-sitemap)
- [x] Customizable sitemap working
- [x] Notifies search engines (Google, Bing) of new sitemaps
- [x] Gives you complete control over your sitemap contents and naming scheme
- [x] Customizable sitemap compression
- [ ] Intelligent sitemap indexing
- [ ] All of the completed Examples

## Supports: generate kind of sitemaps

### News Sitemaps

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: false, host: "http://example.com"

  def generate do
    create do
      add "index.html", news: [
           publication_name: "Example",
           publication_language: "en",
           title: "My Article",
           keywords: "my article, articles about myself",
           stock_tickers: "SAO:PETR3",
           publication_date: "2011-08-22",
           access: "Subscription",
           genres: "PressRelease"
         ]
    end
  end
end
```

Generated Result

```xml
<url>
 <loc>http://www.example.com/index.html</loc>
 <lastmod>2016-05-30T13:13:12Z</lastmod>
 <news:news>
   <news:publication>
     <news:name>Example</news:name>
     <news:language>en</news:language>
   </news:publication>
   <news:title>My Article</news:title>
   <news:access>Subscription</news:access>
   <news:genres>PressRelease</news:genres>
   <news:keywords>my article, articles about myself</news:keywords>
   <news:stock_tickers>SAO:PETR3</news:stock_tickers>
   <news:publication_date>2011-08-22</news:publication_date>
 </news:news>
</url>
```

Look at [Creating a Google News Sitemap](https://support.google.com/news/publisher/answer/74288) as required.

### Image sitemaps

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: false, host: "http://example.com"

  def generate do
    create do
      add "index.html", images: [
           loc: "http://example.com/image.jpg",
           caption: "Caption",
           title: "Title",
           license: "https://github.com/ikeikeikeike/sitemap/blob/master/LICENSE",
           geo_location: "Limerick, Ireland",
         ]
    end
  end
end
```

Generated Result

```xml
<url>
 <loc>http://www.example.com/image.html</loc>
 <lastmod>2016-05-31T13:32:40Z</lastmod>
 <image:image>
   <image:loc>http://example.com/image.jpg</image:loc>
   <image:caption>Caption</image:caption>
   <image:title>Title</image:title>
   <image:license>https://github.com/ikeikeikeike/sitemap/blob/master/LICENSE</image:license>
   <image:geo_location>Limerick, Ireland</image:geo_location>
 </image:image>
</url>
```

Look at [Image sitemaps](https://support.google.com/webmasters/answer/178636) as required.

### Video sitemaps

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: true, host: "http://example.com"

  def generate do
    create do
      add "index.html", videos: [
           thumbnail_loc: "http://www.example.com/thumbs/123.jpg",
           title: "Grilling steaks for summer",
           description: "Alkis shows you how to get perfectly done steaks every time",
           content_loc: "http://www.example.com/video123.flv",
           player_loc: "http://www.example.com/videoplayer.swf?video=123",
           allow_embed: true,
           autoplay: true,
           duration: 600,
           expiration_date: "2009-11-05T19:20:30+08:00",
           publication_date: "2007-11-05T19:20:30+08:00",
           rating: 0.5,
           view_count: 1000,
           tags: ~w(tag1 tag2 tag3),
           tag: "tag4",
           category: "Category",
           family_friendly: true,
           restriction: "IE GB US CA",
           relationship: true,
           gallery_loc: "http://cooking.example.com",
           gallery_title: "Cooking Videos",
           price: "1.99",
           price_currency: "EUR",
           price_type: "own",
           price_resolution: "HD",
           uploader: "GrillyMcGrillerson",
           uploader_info: "http://www.example.com/users/grillymcgrillerson",
           live: true,
           requires_subscription: false
         ]
    end
  end
end

```

Generated Result

```xml
<url>
 <loc>http://www.example.com/video.html</loc>
 <lastmod>2016-05-31T12:51:47Z</lastmod>
 <video:video>
   <video:title>Grilling steaks for summer</video:title>
   <video:description>Alkis shows you how to get perfectly done steaks every time</video:description>
   <video:player_loc allow_embed="yes" autoplay="ap=1">http://www.example.com/videoplayer.swf?video=123</video:player_loc>
   <video:content_loc>http://www.example.com/video123.flv</video:content_loc>
   <video:thumbnail_loc>http://www.example.com/thumbs/123.jpg</video:thumbnail_loc>
   <video:duration>600</video:duration>
   <video:gallery_loc title="Cooking Videos">http://cooking.example.com</video:gallery_loc>
   <video:rating>0.5</video:rating>
   <video:view_count>1000</video:view_count>
   <video:expiration_date>2009-11-05T19:20:30+08:00</video:expiration_date>
   <video:publication_date>2007-11-05T19:20:30+08:00</video:publication_date>
   <video:tag>tag1</video:tag>
   <video:tag>tag2</video:tag>
   <video:tag>tag3</video:tag>
   <video:tag>tag4</video:tag>
   <video:category>Category</video:category>
   <video:family_friendly>yes</video:family_friendly>
   <video:restriction relationship="allow">IE GB US CA</video:restriction>
   <video:uploader info="http://www.example.com/users/grillymcgrillerson">GrillyMcGrillerson</video:uploader>
   <video:price currency="EUR" resolution="HD" type="own">1.99</video:price>
   <video:live>yes</video:live>
   <video:requires_subscription>no</video:requires_subscription>
 </video:video>
</url>
```

Look at [Video sitemaps](https://developers.google.com/webmasters/videosearch/sitemaps#adding-video-content-to-a-sitemap) as required.

### Alternate Links

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: true, host: "http://example.com"

  def generate do
    create do
      add "index.html", alternates: [
           href: "http://www.example.de/index.html",
           lang: "de",
           nofollow: true,
           media: "only screen and (max-width: 640px)"
         ]
    end
  end
end
```

Generated Result

```xml
<url>
 <loc>http://www.example.com/video.html</loc>
 <lastmod>2016-06-01T14:05:05Z</lastmod>
 <xhtml:link href="http://www.example.de/index.html" hreflang="de" media="only screen and (max-width: 640px)" rel="alternate nofollow"/>
</url>
```

Look at [Alternate Links](https://support.google.com/webmasters/answer/2620865) as required.

### Geo Sitemaps

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: true, host: "http://example.com"

  def generate do
    create do
      add "geo.html", alternates: [
           format: "kml"
         ]
    end
  end
end
```

Generated Result

```xml
<url>
 <loc>http://www.example.com/geo.html</loc>
 <lastmod>2016-06-01T14:15:25Z</lastmod>
 <geo:geo>
   <geo:format>kml</geo:format>
 </geo:geo>
</url>
```

Look at [Geo Sitemaps](https://support.google.com/webmasters/answer/94555) as required.

### Mobile Sitemaps

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: true, host: "http://example.com"

  def generate do
    create do
      add "mobile.html", priority: 0.5, changefreq: "hourly", mobile: true
    end
  end
end
```

Generated Result

```xml
<url>
 <loc>http://www.example.com/mobile.html</loc>
 <lastmod>2016-06-01T14:24:44Z</lastmod>
 <changefreq>hourly</changefreq>
 <priority>0.5</priority>
 <mobile:mobile/>
</url>
```

Look at [Mobile Sitemaps](https://support.google.com/webmasters/answer/6082207) as required.

### PageMap sitemap

```elixir
defmodule MyApp.Sitemaps do
  use Sitemaps, compress: true, host: "http://example.com"

  def generate do
    create do
      add "pagemap.html", pagemap: [
        dataobjects: [[
          type: "document",
          id: "hibachi",
          attributes: [
            [name: "name",   value: "Dragon"],
            [name: "review", value: "3.5"],
          ]
        ]]
      ]
    end
  end
end
```

Generated Result

```xml
<url>
 <loc>http://www.example.com/pagemap.html</loc>
 <lastmod>2016-06-02T17:01:17Z</lastmod>
 <PageMap>
   <DataObject id="hibachi" type="document">
     <Attribute name="name">Dragon</Attribute>
     <Attribute name="review">3.5</Attribute>
   </DataObject>
 </PageMap>
</url>
```

Look at [PageMap sitemap](https://developers.google.com/custom-search/docs/structured_data#addtositemaps) as required.

### Additional links into the Sitemap Index

```elixir
create do
  add_to_index "/mysitemap1.xml.gz"
  add_to_index "/alternatemap.xml"
  add_to_index "/changehost.xml.gz", host: "http://something.com"

  add ...
  add ....
end
```

Generated result

```xml
<?xml version='1.0' encoding='utf-8'?>
<sitemapindex xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemalocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
 <sitemap>
   <loc>http://example.com/mysitemap1.xml.gz</loc>
   <lastmod>2017-05-19T11:42:45+09:00</lastmod>
 </sitemap>
 <sitemap>
   <loc>http://example.com/mysitemap2.xml.gz</loc>
   <lastmod>2017-05-19T11:42:45+09:00</lastmod>
 </sitemap>
 <sitemap>
   <loc>http://something.com/changehost.xml.gz</loc>
   <lastmod>2017-05-19T11:42:45+09:00</lastmod>
 </sitemap>
 <sitemap>
   <loc>http://example.com/sitemap1.xml.gz</loc>
   <lastmod>2017-05-19T11:42:45+09:00</lastmod>
 </sitemap>
</sitemapindex>
```

### Inspired by

- [sitemap_generator](http://github.com/kjvarga/sitemap_generator)
- [go-sitemap-generator](http://github.com/ikeikeikeike/go-sitemap-generator)
