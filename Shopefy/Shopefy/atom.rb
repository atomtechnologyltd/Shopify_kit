module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class AtomGateway < Gateway
      self.test_url = 'https://paynetzuat.atomtech.in/paynetz/epi/fts'
      self.live_url = 'https://payment.atomtech.in/paynetz/epi/fts'

      self.supported_countries = ['INR']
      self.default_currency = 'INR'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'http://www.example.net/'
      self.display_name = 'Atom Gateway'
      
      @login = ""
      @password=""
      @prodid=""
      @return_url="http://localhost/shopify/response"
     
      @modifiedDate  = Time.now.strftime("%d/%m/%Y") + "%20" + Time.now.strftime("%H:%M:%S")
      @ttype    = "NBFundTransfer"
      @txnscamt = 0
      @defaultClientCode="XYZ123"
      @custacc    = "123456789012"
      

      def initialize(options={})
        #requires!(options, :login, :password,:prodid,:return_url)
        super
      end

      def purchase(money, payment, options={})
        @post_url = (test? ? test_url : live_url)
        @post_url   = @post_url + "?login=" + @login 
        @post_url   = @post_url + "&pass="  + @password
        @post_url   = @post_url + "&ttype="   + @ttype 
        @post_url   = @post_url + "&prodid=" + @prodid
        @post_url   = @post_url + "&amt=" + money
        @txncurr = (options[:currency] ? options[:currency] : self.default_currency)
        @post_url   = @post_url + "&txncurr=" + @txncurr
        @post_url   = @post_url + "&txnscamt=" + @txnscamt
        @clientcode = (options[:clientcode] ? options[:clientcode] : @defaultClientCode)
        @post_url   = @post_url + "&clientcode=" + @clientcode
        @post_url   = @post_url + "&txnid=" + options[:txnId]
        @post_url   = @post_url + "&date=" + @modifiedDate
        @post_url   = @post_url +"&custacc=" + @custacc
        @post_url   = @post_url +"&ru=" + @return_url
        
        @content = Net::HTTP.get(URI.parse(@post_url))
        xml = REXML::Document.new(@content)
        
        my_hash = Hash.from_xml(@content)
        @tempTxnId = my_hash['MMP'] && my_hash['MMP']['MERCHANT'] && my_hash['MMP']['MERCHANT']['RESPONSE'] && my_hash['MMP']['MERCHANT']['RESPONSE']['param'] &&  my_hash['MMP']['MERCHANT']['RESPONSE']['param'][1]
        @token     = my_hash['MMP'] && my_hash['MMP']['MERCHANT'] && my_hash['MMP']['MERCHANT']['RESPONSE'] && my_hash['MMP']['MERCHANT']['RESPONSE']['param'] &&  my_hash['MMP']['MERCHANT']['RESPONSE']['param'][2]
        @post_url   = ""
        @post_url   = (test? ? test_url : live_url)
        @post_url   = @post_url + "?ttype=" + @ttype
        @post_url   = @post_url + "&tempTxnId=" + @tempTxnId
        @post_url   = @post_url + "&token=" + @token
        @post_url   = @post_url + "&txnStage=1" 
        
        params = {}
        params[:ttype] = @ttype
        params[:tempTxnId] = @tempTxnId
        params[:token] = @token
        params[:txnStage] = 1;
        
        #Redirect user to the @post_url
        redirect_to(@post_url)
        
      end

      #Get response here
      def response
        @resp = params[:f_code]
        if @resp == "OK"
            @result = "success"   
         else
             @result = "fail"  
       end
   end  
      
    end
  end
end
