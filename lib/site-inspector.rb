require 'nokogiri'
require 'open-uri'
require 'public_suffix'
require 'gman'
require 'net/http'
require "dnsruby"
require 'yaml'
require 'sniffles'
require "addressable/uri"
require 'typhoeus'
require 'json'
require File.expand_path './site-inspector/cache',      File.dirname(__FILE__)
require File.expand_path './site-inspector/sniffer',    File.dirname(__FILE__)
require File.expand_path './site-inspector/dns',        File.dirname(__FILE__)
require File.expand_path './site-inspector/compliance', File.dirname(__FILE__)

class SiteInspector

  def initialize(domain)
    domain = domain.sub /^http\:/, ""
    domain = domain.sub /^\/+/, ""
    domain = domain.sub /^www\./, ""
    @uri = Addressable::URI.parse "//#{domain}"
    @domain = PublicSuffix.parse @uri.host
    Typhoeus::Config.cache = SiteInspectorCache.new
  end

  def inspect
    "<SiteInspector domain=\"#{domain}\">"
  end

  def uri(ssl=https?,www=www?)
    uri = @uri.clone
    uri.host = "www.#{uri.host}" if www
    uri.scheme = ssl ? "https" : "http"
    uri
  end

  def domain
    non_www? ? @domain : PublicSuffix.parse("www.#{@uri.host}")
  end

  def request(ssl=false, www=false, followlocation=true)
    Typhoeus::Request.get(uri(ssl, www), followlocation: followlocation, timeout: 10)
  end

  def response
    @response ||= begin
      if response = request(false, false) and response.success?
        @non_www = true
        response
      elsif response = request(false, true) and response.success?
        @non_www = false
        response
      else
        false
      end
    end
  end

  def timed_out?
    response && response.timed_out?
  end

  def doc
    @doc ||= Nokogiri::HTML response.body if response
  end

  def body
    doc.to_s
  end

  def load_data(name)
    YAML.load_file File.expand_path "./data/#{name}.yml", File.dirname(__FILE__)
  end

  def government?
    Gman.valid? domain.to_s
  end

  def https?
    @https ||= request(true, www?).success?
  end
  alias_method :ssl?, :https?

  def enforce_https?
    return false unless https?
    @enforce_https ||= begin
      response = request(false, www?)
      if response.effective_url
        Addressable::URI.parse(response.effective_url).scheme == "https"
      else
        puts response.inspect
        false
      end
    end
  end

  def www?
    response && response.effective_url && !!response.effective_url.match(/https?:\/\/www\./)
  end

  def non_www?
    response && @non_www
  end

  def redirect?
    !!redirect
  end

  def redirect
    @redirect ||= begin
      if location = request(https?, www?, false).headers["location"]
        redirect_domain = SiteInspector.new(location).domain
        redirect_domain.to_s if redirect_domain.to_s != domain.to_s
      end
    end
  end

  def to_json
    {
      :government => government?,
      :live => !!response,
      :ssl => https?,
      :enforce_https => enforce_https?,
      :non_www => non_www?,
      :ip => ip,
      :hostname => hostname,
      :ipv6 => ipv6?,
      :dnssec => dnsec?,
      :cdn => cdn,
      :google_apps => google_apps?,
      :could_provider => cloud_provider,
      :server => server,
      :cms => cms,
      :analytics => analytics,
      :javascript => javascript,
      :advertising => advertising,
      :slash_data => slash_data?,
      :slash_developer => slash_developer?,
      :data_dot_json => data_dot_json?
    }.to_json
  end
end
