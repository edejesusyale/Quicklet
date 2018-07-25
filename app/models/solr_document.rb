
require 'rsolr'

class SolrDocument

  attr_reader :response, :_source
  alias_method :solr_response, :response

  delegate :[], :key?, :keys, :to_h, :as_json, :each, :symbolize_keys, to: :_source

  def valid_viewopt?
    AppConfig::Yaml::APP_CONFIG['valid_viewopts'].include? self[:viewopt_ssi]
  end

  def will_display_in_production?
    self.valid_viewopt? && AppConfig::Yaml::APP_CONFIG['production_states'].include?(self[:state_ssi])
  end

  def valid_document?
    #self[:active_fedora_model_ssim] && !self[:active_fedora_model_ssim].empty?
    puts "true"
    true
  end

  def state_friendly_name
    if self[:state_ssi] == 'D'
      'Deleted'
    elsif self[:state_ssi] == 'A'
      'Active'
    elsif self[:state_ssi] == 'I'
      'Inactive'
    else
      "Unknown: #{self[:state_ssi]}"
    end
  end

  def will_display_in_test?
    self.valid_viewopt? && AppConfig::Yaml::APP_CONFIG['test_states'].include?(self[:state_ssi])
  end

  def initialize(source_doc = {}, response = nil)
    @_source = ActiveSupport::HashWithIndifferentAccess.new(source_doc).freeze
    @response = response
  end

  def datastream_info
    info = {}
    object_profile = JSON.parse(self[:object_profile_ssm].first)
    if object_profile
      datastreams = object_profile['datastreams']
      if datastreams
        datastreams.each { |key,value|
          info[key] = value
        }
      end
    end
    info
  end

  def datastream_size? datastream_id
    ds_info = datastream_info[datastream_id]
    ds_size = 0
    if ds_info
      ds_size = ds_info['dsSize']
    end
    ds_size.to_i
  end

  def stream_exists? datastream_id
    datastream_size?(datastream_id) > 0
  end

end
