#!/usr/bin/env ruby
require 'net/http'
require 'uri'

class GetUSGSData
  attr_accessor :state_codes

  def initialize(state_codes=[])
    # site says 100,000 limit at a time
    # no known documentation on how to "paginate" or get the next 100,000 so we can't return more
    if state_codes.empty?
      @state_codes =  ["al","ak","aq","az","ar","ca","co","ct","de","dc","fl","ga","gu","hi","id","il","in","ia","ks","ky","la","me","md","ma","mi","mn","ms","mo","mt","ne","nv","nh","nj","nm","ny","nc","nd","mp","oh","ok","or","pa","pr","ri","sc","sd","tn","tx","ut","vt","vi","va","wa","wv","wi","wy"]
    else
      @state_codes = state_codes
    end
  end

  def run
    # lets start by getting all the sites we can loop through and get the data for each site
    state_codes.each do |state|
      puts state
      params = { :stateCd => state }

      # http://waterservices.usgs.gov/nwis/site/?stateCd=ny by state
      response = get_http_response('https://waterservices.usgs.gov/nwis/site', params)

      doc = response.body
      doc_array = response.body.split("\n")
      # then loop return and get each of the site codes
      doc_array.each do |line|
        # this means its a line with valuable data in it
        if line.start_with?("USGS")
          line_array = line.split("\t")
          site_code = line_array[1] # this assumes that the second column is always the site code
          puts site_code #just outputting this for now
          # now we have the site code so we can do stuff with it, like get the daily values or the instaneaous values or the statistics values (see options here: https://waterservices.usgs.gov/rest/), the difficulty with these is that there is a ton of data so you need to do it by site_code and then probably do it by dates to limit the amount of data coming back
          # the instaneaous values only go back to Oct 1 2007 - https://waterservices.usgs.gov/rest/IV-Service.html, need params like http://waterservices.usgs.gov/nwis/iv/?site=904027710000007&startDt=2017-01-01&endDt=2017-01-01
          # the daily values (not sure how far these go back) - http://waterservices.usgs.gov/nwis/dv/?site=01646500&startDt=2017-01-01&endDt=2017-01-01
        end
      end
    end
  end

  def get_http_response(uri, params={})
    uri = URI(uri)
    if !params.empty?
      uri.query = URI.encode_www_form(params)
    end
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPRedirection)
      response = get_http_response(response['location'])
    end
    # should probably set a cap for the number of redirections also
    if response.is_a?(Net::HTTPSuccess)
      return response
    else
      return false
    end
  end

end

GetUSGSData.new(["az"]).run #to run a single state - best for testing
# GetUSGSData.new.run # to run all the states
