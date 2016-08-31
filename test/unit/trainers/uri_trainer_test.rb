require 'test_helper'
require 'yaml'

module NewsScraper::Trainer
  class UriTrainerTest < Minitest::Test
    def test_train_with_defined_scraper_pattern
      NewsScraper::Transformers::Article.any_instance.expects(:transform)
      NewsScraper::Extractors::Article.any_instance.expects(:extract)
      NewsScraper::Trainer::UriTrainer.expects(:no_scrape_defined).never

      NewsScraper::Trainer::UriTrainer.train('google.ca')
    end

    def test_train_with_no_defined_scraper_pattern
      NewsScraper::Transformers::Article.any_instance.expects(:transform).raises(
        NewsScraper::Transformers::ScrapePatternNotDefined.new(root_domain: 'google.ca')
      )
      NewsScraper::Extractors::Article.any_instance.expects(:extract).returns('extract')
      NewsScraper::Trainer::UriTrainer.expects(:no_scrape_defined).with('google.ca', 'extract', 'google.ca')

      capture_subprocess_io do
        NewsScraper::Trainer::UriTrainer.train('google.ca')
      end
    end

    def test_no_scrape_defined_with_no_step_through
      NewsScraper::CLI.expects(:confirm).returns(false)
      NewsScraper::Trainer::UriTrainer.expects(:save_selected_presets).never
      NewsScraper::Trainer::DataType.expects(:train).never

      capture_subprocess_io do
        NewsScraper::Trainer::UriTrainer.no_scrape_defined('google.ca', '', 'google.ca')
      end
    end

    def test_no_scrape_defined_with_no_save
      NewsScraper::CLI.expects(:confirm).twice.returns(true, false)
      NewsScraper::Transformers::Article.expects(:scrape_patterns).returns('presets' => mock_presets)
      NewsScraper::Trainer::UriTrainer.expects(:save_selected_presets).never
      NewsScraper::Trainer::DataType.expects(:train).returns({})

      capture_subprocess_io do
        NewsScraper::Trainer::UriTrainer.no_scrape_defined('google.ca', '', 'google.ca')
      end
    end

    def test_no_scrape_defined_with_save
      NewsScraper::CLI.expects(:confirm).twice.returns(true, true)
      NewsScraper::Transformers::Article.expects(:scrape_patterns).returns('presets' => mock_presets)
      NewsScraper::Trainer::UriTrainer.expects(:save_selected_presets).with('google.ca', { 'selected_presets' => 'selected_presets' })
      NewsScraper::Trainer::DataType.expects(:train).returns('selected_presets' => 'selected_presets')

      capture_subprocess_io do
        NewsScraper::Trainer::UriTrainer.no_scrape_defined('google.ca', '', 'google.ca')
      end
    end

    def test_save_selected_presets_saves_config
      assert_presets_written('totally-not-there.com')
    end

    def test_save_selected_presets_saves_config_twice
      domain = 'totally-not-there.com'
      assert_presets_written(domain)
      assert_presets_written(domain, presets: mock_presets('.pattern2'), overwrite_confirm: true)
    end

    def test_save_selected_presets_saves_overwrite
      domain = NewsScraper::Transformers::Article.scrape_patterns['domains'].keys.first
      assert_presets_written(domain, overwrite_confirm: true)
    end

    def test_save_selected_presets_no_overwrite
      domain = NewsScraper::Transformers::Article.scrape_patterns['domains'].keys.first
      original_presets = NewsScraper::Transformers::Article.scrape_patterns['domains'][domain]
      assert_equal original_presets, assert_presets_written(domain, overwrite_confirm: false)
    end

    def assert_presets_written(domain, presets: mock_presets('.pattern'), overwrite_confirm: false)
      yaml_path = 'config/article_scrape_patterns.yml'
      NewsScraper::CLI.stubs(:confirm).returns(overwrite_confirm)

      Dir.mktmpdir do |dir|
        # Copy the yaml file to the tmp dir so we don't modify the main file in a test
        tmp_yaml_path = File.join(dir, yaml_path)
        FileUtils.mkpath(File.dirname(tmp_yaml_path))
        FileUtils.cp(yaml_path, tmp_yaml_path)

        # Chdir to the temp dir so we load the temp file
        Dir.chdir(dir) do
          capture_subprocess_io do
            NewsScraper::Trainer::UriTrainer.save_selected_presets(domain, mock_presets)
          end
          assert_equal mock_presets, YAML.load_file(tmp_yaml_path)['domains'][domain] if overwrite_confirm
          YAML.load_file(tmp_yaml_path)['domains'][domain]
        end
      end
    end

    def mock_presets(pattern = '.pattern')
      %w(body description keywords section time title).each_with_object({}) do |p, preset|
        preset[p] = { 'method' => 'css', 'pattern' => pattern }
      end
    end
  end
end
