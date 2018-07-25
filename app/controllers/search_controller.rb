require 'solr_util/yul_solr_searcher'
require 'yaml'
require 'oci8'

class SearchController < ApplicationController
  def search
    solr_searcher = YulSolrSearcher.new
    conn =OCI8.new('splabel','splabel','(DESCRIPTION=(ADDRESS=(PROTOCOL = TCP)(HOST = yul-vgr-tst1.library.yale.internal)(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME=VGER.yul-vgr-tst1.library.yale.internal)))')

    @oci_documents = []
    @documents = []

    q = params[:q]
    @id_list = []
    @invalid_list = []
    @solr_query, @id_list, @invalid_list = query_from_id_list(q)
    @solr_documents = solr_searcher.find_documents(@solr_query)

    @solr_documents.each {|document|
      id = document[:id]
      @cursor = conn.parse("select  TITLE_BRIEF ,AUTHOR ,ISBN,BIB_FORMAT, IMPRINT, EDITION from BIB_TEXT where BIB_ID = #{id}")
      @cursor.exec
      params= []
      while r = @cursor.fetch
        params = r
        puts("hahahaha "+params.to_s)
      end
      puts("hahaha324234ha "+params.to_s)
      oci = {:id => document[:id], :title_display => params[0] , :author_display => params[1] , :isbn_display => params[2], :full_publisher_display => params[4]}
      @documents << [document , oci]
    } unless @solr_documents == :query_failed

    @cursor.close unless @cursor.nil?
    conn.logoff
    if @solr_documents == :query_failed
      @connected = false;
    else
      @connected = true
    end
  end

  def index

    render 'search'

  end

  def query_from_id_list q
    id_list = []
    invalid_list = []
    return nil if q =='' || q.nil?
    q.split(/[\s,]+/).each {|query_component|
      query_component.strip!
      next if !query_component
      if query_component.to_i > 0
        id_list << query_component.to_i
      else
        invalid_list << query_component
      end
    }

    id_query = id_list.map {|id|
      "#{id}"
    }.join(' OR ')



    return id_query, id_list,invalid_list
  end

end