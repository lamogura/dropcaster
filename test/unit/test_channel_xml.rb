require 'helper'
require 'xml/libxml'

class TestChannelXML < Test::Unit::TestCase
  include DropcasterTest

  def setup
    @options = YAML.load_file(File.join(FIXTURES_DIR, Dropcaster::CHANNEL_YML))
    @channel = XML::Document.string(Dropcaster::Channel.new(FIXTURES_DIR, @options).to_rss).find("//rss/channel").first
  end

  def test_item
    item = @channel.find("item").first
    assert(item)

    assert_equal('iTunes Name', item.find('title').first.content)
    assert_equal('iTunes Artist', item.find('itunes:author', NS_ITUNES).first.content)
    assert_equal('iTunes Description (Video Pane)', item.find('itunes:summary', NS_ITUNES).first.content)
    assert_equal('http://example.com/podcasts/everything/AllAboutEverything.jpg', item.find('itunes:image', NS_ITUNES).first['href'])

    enclosure = item.find('enclosure').first
    assert(enclosure)
    assert_equal('http://www.example.com/podcasts/everything/test/fixtures/iTunes.mp3', enclosure['url'])
    assert_equal('58119', enclosure['length'])
    assert_equal('audio/mp3', enclosure['type'])

    guid = item.find('guid').first
    assert(guid)
    assert_equal('false', guid['isPermaLink'])
    assert_equal('77bf84447c0f69ce4a33a18b0ae1e030b82010de', guid.content)

    assert_equal('Sat, 01 Oct 2011 14:08:20 +0200', item.find('pubDate').first.content)
    assert_equal('3', item.find('itunes:duration', NS_ITUNES).first.content)

    # Not used in our fixture yet
    # assert_equal('', item.find('itunes:subtitle', NS_ITUNES).first.content)
    # assert_equal('', item.find('itunes:keywords', NS_ITUNES).first.content)
  end

  def test_attributes_mandatory
    options = {:title => 'Test Channel',
               :url => 'http://www.example.com/',
               :description => 'A test channel',
               :enclosure_base => 'http://www.example.com/foo/bar',
              }
    @channel = XML::Document.string(Dropcaster::Channel.new(FIXTURES_DIR, options).to_rss).find("//rss/channel").first    
    assert_equal('Test Channel', @channel.find('title').first.content)
    assert_equal('http://www.example.com/', @channel.find('link').first.content)
    assert_equal('A test channel', @channel.find('description').first.content)
  end

  def test_attributes_complete
    assert_equal(@options[:title], @channel.find('title').first.content)
    assert_equal(@options[:url], @channel.find('link').first.content)
    assert_equal(@options[:description], @channel.find('description').first.content)
    assert_equal(@options[:subtitle], @channel.find('itunes:subtitle', NS_ITUNES).first.content)
    assert_equal(@options[:language], @channel.find('language').first.content)
    assert_equal(@options[:copyright], @channel.find('copyright').first.content)
    assert_equal(@options[:author], @channel.find('itunes:author', NS_ITUNES).first.content)

    owner = @channel.find('itunes:owner', NS_ITUNES).first
    assert_equal(@options[:owner][:name], owner.find('itunes:name', NS_ITUNES).first.content)
    assert_equal(@options[:owner][:email], owner.find('itunes:email', NS_ITUNES).first.content)

    assert_equal(@options[:image_url], @channel.find('itunes:image', NS_ITUNES).first['href'])
    # TODO :categories: ['Technology', 'Gadgets']
    assert_equal(@options[:explicit], @channel.find('itunes:explicit', NS_ITUNES).first.content)
  end
end