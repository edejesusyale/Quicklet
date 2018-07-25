require 'rsolr'

class YulSolrSearcher

  def find_documents( query )
    begin
      solr = RSolr.connect( url: @url )
      response = solr.post( 'select', params: {q:"#{query}", wt:'ruby', rows: 500, start: 0} )
      response = response['response']
      results = []
      response['docs'].each { |document|

        document = SolrDocument.new(document)
        results << document if document.valid_document?
      }

      results
    rescue
      :query_failed
    end
  end


  def find_document_by_oid( oid )
    begin
      solr = RSolr.connect( url: @url )
      response = solr.get( 'select', params: {q:"oid_isi:#{oid}", wt:'ruby'})
      response = response['response']
      SolrDocument.new(response['docs'].first)
    rescue
      nil
    end
  end

  def find_children_by_oid( oid )
    begin
      solr = RSolr.connect( url: @url)
      response = solr.get( 'select', params: {q:"parentoid_isi:#{oid}", wt:'ruby', sort: 'oid_isi desc', rows: 1000})
      response = response['response']
      results = []
      response['docs'].each { |document|
        document = SolrDocument.new(document)
        results << document
      }
      results
    rescue
      []
    end
  end

  def add_children_to_document_recursive( document )
    children = find_children_by_oid( document['oid_isi'] )
    document[:children] = children
    children.each { |child|
      add_children_to_document(child)
    }
  end


  def query_oids_and_children(oid_list)
    documents = {}
    oid_list.each { |oid|
      doc = find_document_by_oid(oid)
      if doc
        documents[oid] = doc
        add_children_to_document_recursive(doc)
      end
    }

    documents
  end

  def url=(url)
    @url = url
  end
end


