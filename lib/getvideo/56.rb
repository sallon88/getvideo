#coding:utf-8

module Getvideo 
  class Wole
    attr_reader :url
    attr_reader :title

    def initialize(uri)
      @url = uri
      @body = JSON.parse(response)
    end

    def html_url
      info_path
    end

    def id
      if url =~ /\.[html|swf]/
        url.scan(/v_([^\.]+)\.[html|swf]/)[0][0]
      else
        url
      end
    end

    def cover
      "http://img." + @body["img_host"] + "/images/" + @body["URL_pURL"] + "/" + @body["URL_sURL"] + "/" + @body["user_id"] + "i56olo56i56.com_" + @body["URL_URLid"] + ".jpg"
    end

    def flash
      "http://player.56.com/v_#{id}.swf"
    end

    def m3u8
      "http://vxml.56.com/m3u8/#{videoid}"
    end

    def media
      video_list = {}
      fid = "f"+@body["id"][-2,2] +"."
      flv = "http://"+ fid + "r.56.com/"+ fid + @body["URL_host"]+ "/flvdownload/"+ @body["URL_pURL"] + "/"+ @body["URL_sURL"]+"/"+ @body["URL_URLid"]
      video_list["flv"] = []
      video_list["flv"] << flv+ ".flv"
      video_list["flv"] << flv+ "clear.flv"
      video_list["mp4"] = []
      video_list["mp4"] << flv+ "_vga.mp4"
      video_list["mp4"] << flv+ "_qqvga.mp4"
      return video_list
    end

    def play_media
      media["flv"][0]
    end

    def json
      {id: id,
       url: html_url,
       cover: cover,
       title: title,
       m3u8: m3u8,
       flash: flash,
       media: play_media}.to_json
    end

    private

    def videoid
      puts @body["id"]
    end

    def info_path
      if url =~ /\.html/
        url
      else
        "http://www.56.com/u/v_#{id}.html"
      end
    end

    def response
      uri = URI.parse(info_path)
      http = Net::HTTP.new(uri.host, uri.port)
      res = http.get(uri.path)
      doc = Nokogiri::HTML(res.body)
      str = ""
      @title = doc.css("#VideoTitle h1").text
      doc.css("script").each do | s |
        if s.content =~ /var _oFlv_o/
          s.content.split("\n").each do |c|
          str = c.split("=")[1].delete("'") if c =~ /var _oFlv_o/
        end
      end
      end
      return decode56(str.strip)
    end

    def decode56(str)
      c1, c2, c3, c4  = ""
      c5 = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,-1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1]
      c6 = charCodeAt(str, 0)
      c7 = ""
      i = ""
      len = ""
      out = ""
      if @de.nil?
        @de = 1
        c7 = decode56(str)
        str = c7[c6..-1]
      end

      len = str.length
      i = 0
      out = ""

      while i < len
        begin
          c1 = c5[charCodeAt(str, i = i+1) & 0xff]
        end while i < len &&  c1 == -1
        break if c1 == -1

        begin
          c2 = c5[charCodeAt(str, i=i+1) & 0xff]
        end while i < len && c2 == -1
        break if c2 == -1


        out += ((c1 << 2) | ((c2 & 0x30) >> 4)).chr

        begin
          c3 = charCodeAt(str, i=i+1) & 0xff
          return out if c3 == 61
          c3 = c5[c3]
        end while i < len && c3 == -1

        break if c3 == -1
        out += (((c2 & 0XF) << 4) | ((c3 & 0x3C) >> 2)).chr

        begin
          c4 = charCodeAt(str, i=i+1) & 0xff
          return out if c4 == 61
          c4 = c5[c4]
        end while i < len && c4 == -1
        break if c4 == -1

        out += (((c3&0x03) << 6) | c4).chr
      end

      return out
    end

    def charCodeAt(str, i)
      if str[i,1].empty?
        return 0
      else
        return str[i,1].ord
      end
    end


  end
end