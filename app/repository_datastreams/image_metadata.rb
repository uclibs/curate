require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/image', __FILE__)

class ImageMetadata < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.alternate_title(to: "title#alternate", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.bibliographic_citation({in: RDF::DC, to: 'bibliographicCitation'}) do |index|
      index.as :stored_searchable
    end

    map.college({to: "subject#college", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coverage_spatial({to: "coverage#spatial", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coverage_temporal({to: "coverage#temporal", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.cultural_context(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.date_created(:to => "date#created", :in => RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
      index.as :stored_searchable
    end

    map.date_photographed(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
      index.as :stored_searchable
    end


    map.department({to: "subject#department", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.genre({to: "type#genre", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.identifier({to: "identifier#doi", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable
    end

    map.inscription(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.location(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.measurements(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.material(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.note({to: 'description#note', in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable
    end

    map.publisher(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.publisher_digital({to:"publisher#digital", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.requires({in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.rights(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.source(in: RDF::Image) do |index|
      index.as :stored_searchable
    end

    map.subject(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.type(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
  end
end

