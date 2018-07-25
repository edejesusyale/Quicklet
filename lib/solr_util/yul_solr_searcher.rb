require 'rsolr'

class YulSolrSearcher

  def find_documents( query )
    begin
      solr = RSolr.connect( url: "http://hydratest.library.yale.edu:8083/solr/clio-hydra" )
      response = solr.post( 'select', params: {q:"#{query}", wt:'ruby', rows: 500, start: 0,defType: 'edismax',qf: "id",op: "OR"} )
      response = response['response']
      puts("response: " + response.to_s + " || Query: " + query)
      results = []
      response['docs'].each { |document|
        document = SolrDocument.new(document)
        results << document #if document.valid_document?
      }
      puts(results)
      results
    rescue
      :query_failed
    end
  end



  def url=(url)
    @url = url
  end
end


