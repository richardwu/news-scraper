module NewsScraper
  class Scraper
    # Initialize a Scraper object
    #
    # *Params*
    # - <code>query</code>: a keyword arugment specifying the query to scrape
    #
    def initialize(query:)
      @query = query
    end

    # Fetches articles from Extraction sources and scrapes the results
    #
    # *Yields*
    # - Will yield individually extracted articles
    #
    # *Raises*
    # - Will raise a <code>Transformers::ScrapePatternNotDefined</code> if an article is not in the root domains
    #   - Will <code>yield</code> the error if a block is given
    #   - Root domains are specified by the <code>article_scrape_patterns.yml</code> file
    #   - This root domain will need to be trained, it would be helpful to have a PR created to train the domain
    #   - You can train the domain by running <code>NewsScraper::Trainer::UrlTrainer.new(URL_TO_TRAIN).train</code>
    #
    # *Returns*
    # - <code>transformed_articles</code>: The transformed articles fetched from the extracted sources
    #
    def scrape
      article_urls = Extractors::GoogleNewsRss.new(query: @query).extract

      transformed_articles = []

      article_urls.each do |article_url|
        payload = Extractors::Article.new(url: article_url).extract
        article_transformer = Transformers::Article.new(url: article_url, payload: payload)

        begin
          transformed_article = article_transformer.transform
          transformed_articles << transformed_article
          yield transformed_article if block_given?
        rescue Transformers::ScrapePatternNotDefined => e
          raise e unless block_given?
          yield e
        end
      end

      transformed_articles
    end
  end
end
