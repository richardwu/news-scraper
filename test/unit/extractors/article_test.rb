require 'test_helper'

class ArticleTest < Minitest::Test
  include ExtractorsTestHelpers

  def test_correctly_extracts_body_from_given_url
    site = 'http://somesite.com'
    expected_body = 'somesite body response'
    stub_http_request(url: site, body: expected_body)
    capture_subprocess_io do
      extractor = NewsScraper::Extractors::Article.new(url: site)
      assert_equal expected_body, extractor.extract
    end
  end
end
